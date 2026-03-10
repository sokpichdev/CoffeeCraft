//
//  RatingService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import FirebaseFirestore
import Foundation

// MARK: - RatingError

enum RatingError: LocalizedError {
    case notEligible // no completed order containing this product
    case alreadySubmitted // tried to call submitRating() when rating exists
    case noRatingToEdit // tried to call editRating() before any submission
    case invalidScore // score outside 1–5
    case productNotFound // product doc missing from Firestore
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notEligible:
            return "You can only rate products from a completed order."
        case .alreadySubmitted:
            return "You've already rated this product."
        case .noRatingToEdit:
            return "No existing rating found to edit."
        case .invalidScore:
            return "Rating score must be between 1 and 5."
        case .productNotFound:
            return "Product not found. Please try again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - RatingService

final class RatingService {

    // MARK: Singleton

    static let shared = RatingService()
    private init() {}

    // MARK: Private

    private let db = Firestore.firestore()

    private func productsRef() -> CollectionReference {
        db.collection("products")
    }

    private func ratingsRef(productId: String) -> CollectionReference {
        productsRef().document(productId).collection("ratings")
    }

    private func reviewsRef(productId: String) -> CollectionReference {
        productsRef().document(productId).collection("reviews")
    }

    private func ordersRef() -> CollectionReference {
        db.collection("orders")
    }
}

// MARK: - Proof of Purchase

extension RatingService {

    /// Checks whether the user has at least one Completed order that contains
    /// the given product (via the flat productIds[] array added in Phase 7).
    ///
    /// Returns the orderId of the first qualifying order (used as proof reference
    /// when writing the rating doc), or nil when no qualifying order exists.
    ///
    /// - Complexity: Single Firestore index query, limit(to: 1) — fast even at scale.
    func checkProofOfPurchase(userId: String, productId: String) async throws -> String? {
        AppLog.firestore.debug("🔍 RatingService.checkProofOfPurchase — userId: \(userId), productId: \(productId)")

        let snapshot = try await ordersRef()
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "Completed")
            .whereField("productIds", arrayContains: productId)
            .limit(to: 1)
            .getDocuments()

        let orderId = snapshot.documents.first?.documentID

        if let orderId {
            AppLog.firestore.debug("✅ Proof of purchase found — orderId: \(orderId)")
        } else {
            AppLog.firestore.debug("⚠️ No qualifying order found for productId: \(productId)")
        }

        return orderId
    }
}

// MARK: - Fetch

extension RatingService {

    /// Reads the current user's rating doc for a product, if it exists.
    /// Returns nil when the user has never rated this product.
    /// Called by ReviewViewModel on view appear to pre-populate the star picker.
    func fetchUserRating(userId: String, productId: String) async throws -> UserRating? {
        AppLog.firestore.debug("🔍 RatingService.fetchUserRating — userId: \(userId), productId: \(productId)")

        let doc    = try await ratingsRef(productId: productId).document(userId).getDocument()
        let rating = try? doc.data(as: UserRating.self)

        AppLog.firestore.debug("✅ fetchUserRating — found: \(rating != nil)")
        return rating
    }

    /// Fetches a paginated page of visible reviews for a product, newest first.
    ///
    /// - Parameters:
    ///   - productId: The product to fetch reviews for.
    ///   - limit: Page size. Default 10.
    ///   - after: Firestore cursor from the last document of the previous page.
    ///            Pass nil for the first page.
    ///
    /// - Returns: A tuple of the decoded reviews and the last DocumentSnapshot
    ///            (pass this back as `after` for the next page).
    ///            When the returned array has fewer items than `limit`,
    ///            there are no more pages (ReviewViewModel sets canLoadMore = false).
    func fetchReviews(
        productId: String,
        limit: Int = 10,
        after cursor: Any? = nil
    ) async throws -> (reviews: [Review], lastDocument: DocumentSnapshot?) {

        AppLog.firestore.debug("🔍 RatingService.fetchReviews — productId: \(productId), limit: \(limit), hasCursor: \(cursor != nil)")

        var query: Query = reviewsRef(productId: productId)
            .whereField("isHidden", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)

        // Attach pagination cursor for pages beyond the first.
        // cursor is typed as Any? so callers (ReviewViewModel) don't need a
        // FirebaseFirestore import — we safely cast here where it's already imported.
        if let snapshot = cursor as? DocumentSnapshot {
            query = query.start(afterDocument: snapshot)
        }

        let snapshot = try await query.getDocuments()
        let reviews  = snapshot.documents.compactMap { try? $0.data(as: Review.self) }

        AppLog.firestore.debug("✅ fetchReviews — loaded \(reviews.count) reviews")

        return (reviews: reviews, lastDocument: snapshot.documents.last)
    }
}

// MARK: - Submit (first-time)

extension RatingService {

    /// Submits a brand-new rating (and optional review) for a product.
    ///
    /// Operation order:
    ///   1. Guard: score must be 1–5
    ///   2. Guard: no existing rating (duplicate check)
    ///   3. Transaction: recalculate avgRating and increment ratingCount on product doc
    ///   4. Write ratings/{userId} doc
    ///   5. If body is provided: write reviews/{autoId} doc, then patch reviewId back
    ///      into ratings/{userId} for the edit-path back-reference
    ///
    /// - Parameters:
    ///   - productId: The product being rated.
    ///   - userId:    Firebase Auth UID of the reviewer.
    ///   - userName:  Display name snapshot — stored on review doc.
    ///   - orderId:   Proof-of-purchase order ID from checkProofOfPurchase().
    ///   - score:     Integer 1–5.
    ///   - body:      Optional review text (max 280 chars enforced in UI).
    func submitRating(
        productId: String,
        userId: String,
        userName: String,
        orderId: String,
        score: Int,
        body: String?
    ) async throws {
        guard (1...5).contains(score) else {
            AppLog.firestore.error("❌ submitRating — invalid score: \(score)")
            throw RatingError.invalidScore
        }

        AppLog.firestore.info("⭐ RatingService.submitRating — productId: \(productId), score: \(score), hasBody: \(body != nil)")

        // MARK: Guard — no existing rating
        let existingRating = try await fetchUserRating(userId: userId, productId: productId)
        guard existingRating == nil else {
            AppLog.firestore.error("❌ submitRating — rating already exists for userId: \(userId)")
            throw RatingError.alreadySubmitted
        }

        let productRef = productsRef().document(productId)
        let ratingRef  = ratingsRef(productId: productId).document(userId)

        // MARK: Step 1 — Transaction: update avgRating + ratingCount on product
        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let productSnap = try transaction.getDocument(productRef)

                guard productSnap.exists else {
                    throw RatingError.productNotFound
                }

                let oldCount = productSnap.data()?["ratingCount"] as? Int    ?? 0
                let oldAvg   = productSnap.data()?["avgRating"]   as? Double ?? 0.0
                let newCount = oldCount + 1

                // Weighted running average:
                // newAvg = (oldAvg * oldCount + newScore) / newCount
                let newAvg = (oldAvg * Double(oldCount) + Double(score)) / Double(newCount)
                let rounded = (newAvg * 10).rounded() / 10   // round to 1 decimal place

                AppLog.firestore.debug("📊 avg update: \(oldAvg) × \(oldCount) + \(score) → \(rounded) (\(newCount) ratings)")

                transaction.updateData([
                    "avgRating":   rounded,
                    "ratingCount": newCount
                ], forDocument: productRef)

                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.debug("✅ product avgRating transaction complete")

        // MARK: Step 2 — Write ratings/{userId}
        let now = Timestamp(date: Date())
        let ratingData: [String: Any] = [
            "score":     score,
            "orderId":   orderId,
            "createdAt": now
            // reviewId intentionally omitted — patched in Step 4 if body provided
        ]
        try await ratingRef.setData(ratingData)

        AppLog.firestore.debug("✅ ratings/\(userId) written")

        // MARK: Step 3 — Write reviews/{autoId} if body provided
        guard let body, !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            AppLog.firestore.info("✅ submitRating complete (stars only, no review body)")
            return
        }

        let review = Review.create(
            userId: userId,
            userName: userName,
            orderId: orderId,
            rating: score,
            body: body
        )

        let reviewRef = reviewsRef(productId: productId).document()
        try await reviewRef.setData(try Firestore.Encoder().encode(review))

        AppLog.firestore.debug("✅ reviews/\(reviewRef.documentID) written")

        // MARK: Step 4 — Patch reviewId back-reference into ratings/{userId}
        // This lets editRating() find the review doc on edit without an extra query.
        try await ratingRef.updateData(["reviewId": reviewRef.documentID])

        AppLog.firestore.info("✅ submitRating complete — score: \(score), reviewId: \(reviewRef.documentID)")
    }
}

// MARK: - Edit (update existing)

extension RatingService {

    /// Updates an existing rating and/or review.
    ///
    /// Operation order:
    ///   1. Fetch existing ratings/{userId} — throws noRatingToEdit if missing
    ///   2. Transaction: recalculate avgRating using old score → new score
    ///   3. Update ratings/{userId} with new score + updatedAt
    ///   4. If reviewId exists on the rating: update review body + rating field + updatedAt
    ///   5. If no reviewId but newBody provided: create a new review doc and patch back-reference
    ///
    /// The avg recalculation formula for an edit (count stays the same):
    ///   newAvg = (oldAvg × count − oldScore + newScore) / count
    ///
    /// - Parameters:
    ///   - productId: The product whose rating is being edited.
    ///   - userId:    Firebase Auth UID of the reviewer.
    ///   - userName:  Current display name (used only when creating a new review doc).
    ///   - newScore:  Updated integer 1–5.
    ///   - newBody:   Updated review text. Pass nil to leave existing text unchanged.
    func editRating(
        productId: String,
        userId: String,
        userName: String,
        newScore: Int,
        newBody: String?
    ) async throws {
        guard (1...5).contains(newScore) else {
            AppLog.firestore.error("❌ editRating — invalid score: \(newScore)")
            throw RatingError.invalidScore
        }

        AppLog.firestore.info("✏️ RatingService.editRating — productId: \(productId), newScore: \(newScore)")

        // MARK: Step 1 — Fetch existing rating (need oldScore for avg recalculation)
        guard let existing = try await fetchUserRating(userId: userId, productId: productId) else {
            AppLog.firestore.error("❌ editRating — no existing rating for userId: \(userId)")
            throw RatingError.noRatingToEdit
        }

        let oldScore = existing.score
        let orderId  = existing.orderId

        // Short-circuit: nothing changed
        guard newScore != oldScore || newBody != nil else {
            AppLog.firestore.debug("⚠️ editRating — score unchanged and no new body, skipping write")
            return
        }

        let productRef = productsRef().document(productId)
        let ratingRef  = ratingsRef(productId: productId).document(userId)

        // MARK: Step 2 — Transaction: recalculate avgRating (count unchanged)
        if newScore != oldScore {
            try await db.runTransaction { transaction, errorPointer -> Any? in
                do {
                    let productSnap = try transaction.getDocument(productRef)

                    guard productSnap.exists else {
                        throw RatingError.productNotFound
                    }

                    let count  = productSnap.data()?["ratingCount"] as? Int    ?? 1
                    let oldAvg = productSnap.data()?["avgRating"]   as? Double ?? Double(oldScore)

                    // Edit formula — count stays the same, swap old score for new:
                    // newAvg = (oldAvg × count − oldScore + newScore) / count
                    let newAvg  = (oldAvg * Double(count) - Double(oldScore) + Double(newScore)) / Double(count)
                    let rounded = (newAvg * 10).rounded() / 10

                    AppLog.firestore.debug("📊 avg edit: \(oldAvg) × \(count) − \(oldScore) + \(newScore) → \(rounded)")

                    transaction.updateData([
                        "avgRating": max(1.0, min(5.0, rounded)) // clamp to valid range
                    ], forDocument: productRef)

                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }

            AppLog.firestore.debug("✅ product avgRating edit transaction complete")
        }

        // MARK: Step 3 — Update ratings/{userId}
        let now = Timestamp(date: Date())
        try await ratingRef.updateData([
            "score": newScore,
            "updatedAt": now
        ])

        AppLog.firestore.debug("✅ ratings/\(userId) updated — score: \(oldScore) → \(newScore)")

        // MARK: Step 4 — Update existing review doc (if one was previously written)
        if let reviewId = existing.reviewId {
            let reviewRef = reviewsRef(productId: productId).document(reviewId)
            var reviewUpdate: [String: Any] = [
                "rating": newScore,
                "updatedAt": now
            ]
            if let newBody {
                reviewUpdate["body"] = newBody
            }
            try await reviewRef.updateData(reviewUpdate)

            AppLog.firestore.debug("✅ reviews/\(reviewId) updated")

        // MARK: Step 5 — No prior review but new body provided → create review now
        } else if let newBody, !newBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let review = Review.create(
                userId: userId,
                userName: userName,
                orderId: orderId,
                rating: newScore,
                body: newBody
            )
            let reviewRef = reviewsRef(productId: productId).document()
            try await reviewRef.setData(try Firestore.Encoder().encode(review))

            // Patch back-reference
            try await ratingRef.updateData(["reviewId": reviewRef.documentID])

            AppLog.firestore.debug("✅ new review created during edit — reviewId: \(reviewRef.documentID)")
        }

        AppLog.firestore.info("✅ editRating complete — \(oldScore)→\(newScore), productId: \(productId)")
    }
}

// MARK: - Helpful Toggle

extension RatingService {

    /// Atomically toggles the "Helpful" state for a review.
    ///
    /// Uses a Firestore transaction to read the current helpfulBy array and
    /// decide the correct direction (add vs remove), keeping helpfulCount
    /// perfectly in sync with helpfulBy.count at all times.
    ///
    /// - Parameters:
    ///   - productId: The product the review belongs to.
    ///   - reviewId:  The review document ID.
    ///   - userId:    The user toggling helpful.
    ///
    /// - Returns: The new helpful state (true = now marked helpful).
    @discardableResult
    func toggleHelpful(
        productId: String,
        reviewId: String,
        userId: String
    ) async throws -> Bool {

        AppLog.firestore.debug("👍 RatingService.toggleHelpful — reviewId: \(reviewId), userId: \(userId)")

        let reviewRef = reviewsRef(productId: productId).document(reviewId)
        var nowHelpful = false

        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let snap = try transaction.getDocument(reviewRef)
                let helpfulBy = snap.data()?["helpfulBy"] as? [String] ?? []
                let alreadyIn = helpfulBy.contains(userId)

                if alreadyIn {
                    // Remove: un-helpful
                    transaction.updateData([
                        "helpfulBy": FieldValue.arrayRemove([userId]),
                        "helpfulCount": FieldValue.increment(Int64(-1))
                    ], forDocument: reviewRef)
                    nowHelpful = false
                    AppLog.firestore.debug("👎 removed helpful — reviewId: \(reviewId)")
                } else {
                    // Add: mark helpful
                    transaction.updateData([
                        "helpfulBy": FieldValue.arrayUnion([userId]),
                        "helpfulCount": FieldValue.increment(Int64(1))
                    ], forDocument: reviewRef)
                    nowHelpful = true
                    AppLog.firestore.debug("👍 added helpful — reviewId: \(reviewId)")
                }

                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        AppLog.firestore.info("✅ toggleHelpful complete — nowHelpful: \(nowHelpful)")
        return nowHelpful
    }
}
