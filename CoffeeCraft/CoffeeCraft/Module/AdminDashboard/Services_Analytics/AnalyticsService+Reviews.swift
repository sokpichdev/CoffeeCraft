//
//  AnalyticsService+Reviews.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import FirebaseFirestore
import Foundation

extension AnalyticsService {

    // MARK: - Fetch All Reviews (Collection Group)

    /// Fetches all reviews across every product using a collectionGroup query.
    /// Cross-references the products collection for product names.
    ///
    /// ⚠️  Requires a Firestore composite index on:
    ///     Collection group: reviews
    ///     Fields: timestamp DESC
    ///
    /// Firestore will print a clickable creation link on first run.
    func fetchAllReviews(filter: ReviewFilter,
                         pageSize: Int = 30) async throws -> ([ReviewItem], DocumentSnapshot?) {
        // Step 1: Fetch all product names in one read for the join
        let productCatalog = try await fetchProductNameMap()

        // Step 2: Build the base collectionGroup query
        var query: Query = db.collectionGroup("reviews")
            .order(by: Firebase.Products.Reviews.createdAt, descending: true)
            .limit(to: pageSize + 1)

        // Rating filter — Firestore supports equality on collectionGroup
        if let stars = filter.rating {
            query = db.collectionGroup("reviews")
                .whereField(Firebase.Products.Reviews.rating, isEqualTo: stars)
                .order(by: Firebase.Products.Reviews.createdAt, descending: true)
                .limit(to: pageSize + 1)
        }

        // Visibility filter
        switch filter.visibility {
        case .visible:
            query = query.whereField(Firebase.Products.Reviews.isHidden, isEqualTo: false)
        case .hidden:
            query = query.whereField(Firebase.Products.Reviews.isHidden, isEqualTo: true)
        case .all:
            break
        }

        let snapshot = try await query.getDocuments()
        var items = snapshot.documents.compactMap { doc -> ReviewItem? in
            mapToReviewItem(doc, productCatalog: productCatalog)
        }

        // Product filter — client-side after fetch (avoids extra composite index)
        if let productId = filter.productId {
            items = items.filter { $0.productId == productId }
        }

        let hasMore = snapshot.documents.count > pageSize
        let cursor = hasMore ? snapshot.documents[pageSize - 1] : snapshot.documents.last

        return (Array(items.prefix(pageSize)), cursor)
    }

    /// Next page using a cursor from a previous fetch.
    func fetchMoreReviews(after cursor: DocumentSnapshot,
                          filter: ReviewFilter,
                          pageSize: Int = 30) async throws -> ([ReviewItem], DocumentSnapshot?) {
        let productCatalog = try await fetchProductNameMap()

        var query: Query = db.collectionGroup("reviews")
            .order(by: Firebase.Products.Reviews.createdAt, descending: true)
            .start(afterDocument: cursor)
            .limit(to: pageSize + 1)

        if let stars = filter.rating {
            query = db.collectionGroup("reviews")
                .whereField(Firebase.Products.Reviews.rating, isEqualTo: stars)
                .order(by: Firebase.Products.Reviews.createdAt, descending: true)
                .start(afterDocument: cursor)
                .limit(to: pageSize + 1)
        }

        switch filter.visibility {
        case .visible: query = query.whereField(Firebase.Products.Reviews.isHidden, isEqualTo: false)
        case .hidden: query = query.whereField(Firebase.Products.Reviews.isHidden, isEqualTo: true)
        case .all: break
        }

        let snapshot = try await query.getDocuments()
        var items = snapshot.documents.compactMap { doc -> ReviewItem? in
            mapToReviewItem(doc, productCatalog: productCatalog)
        }

        if let productId = filter.productId {
            items = items.filter { $0.productId == productId }
        }

        let hasMore = snapshot.documents.count > pageSize
        let cursor = hasMore ? snapshot.documents[pageSize - 1] : snapshot.documents.last

        return (Array(items.prefix(pageSize)), cursor)
    }

    // MARK: - Hide / Unhide

    /// Toggles the `isHidden` field on a review document.
    /// The subcollection path is reconstructed from productId + reviewId.
    func setReviewHidden(productId: String,
                         reviewId: String,
                         hidden: Bool) async throws {
        try await db
            .collection(Firebase.Products.collection).document(productId)
            .collection(Firebase.Products.Reviews.collection).document(reviewId)
            .updateData([Firebase.Products.Reviews.isHidden: hidden])
    }

    // MARK: - Review Analytics (per product)

    /// Fetches all reviews for a specific product and computes analytics.
    func fetchReviewAnalytics(productId: String,
                              productName: String) async throws -> ReviewAnalyticsData {
        let snapshot = try await db
            .collection(Firebase.Products.collection).document(productId)
            .collection(Firebase.Products.Reviews.collection)
            .order(by: Firebase.Products.Reviews.createdAt, descending: false)
            .getDocuments()

        let reviews = snapshot.documents.compactMap { doc -> (Int, Bool, Date)? in
            let data = doc.data()
            guard
                let rating = data[Firebase.Products.Reviews.rating] as? Int,
                let timestamp = (data[Firebase.Products.Reviews.createdAt] as? Timestamp)?.dateValue()
            else { return nil }
            let isHidden = data[Firebase.Products.Reviews.isHidden] as? Bool ?? false
            return (rating, isHidden, timestamp)
        }

        let total = reviews.count
        let hidden = reviews.filter { $0.1 }.count
        let ratings = reviews.map { $0.0 }
        let avg = ratings.isEmpty ? 0.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)

        return ReviewAnalyticsData(
            productId: productId,
            productName: productName,
            totalCount: total,
            hiddenCount: hidden,
            avgRating: avg,
            ratingDistribution: buildRatingDistribution(from: ratings),
            ratingOverTime: buildRatingOverTime(from: reviews)
        )
    }

    // MARK: - Product Options (for filter picker)

    /// Returns a list of all products that have at least one review.
    /// Used to populate the product filter picker.
    func fetchReviewedProducts() async throws -> [ProductOption] {
        // Fetch product names cheaply — only name field needed
        let snapshot = try await db.collection(Firebase.Products.collection)
            .order(by: Firebase.Products.name)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            guard let name = doc.data()[Firebase.Products.name] as? String else { return nil }
            return ProductOption(id: doc.documentID, name: name)
        }
    }

    // MARK: - Private Helpers

    private func fetchProductNameMap() async throws -> [String: String] {
        let snapshot = try await db.collection(Firebase.Products.collection).getDocuments()
        var map: [String: String] = [:]
        for doc in snapshot.documents {
            map[doc.documentID] = doc.data()[Firebase.Products.name] as? String ?? "Unknown Product"
        }
        return map
    }

    private func mapToReviewItem(_ doc: DocumentSnapshot,
                                 productCatalog: [String: String]) -> ReviewItem? {
        let data = doc.data() ?? [:]
        guard
            let rating = data[Firebase.Products.Reviews.rating] as? Int,
            let comment = data[Firebase.Products.Reviews.body] as? String,
            let timestamp = (data[Firebase.Products.Reviews.createdAt] as? Timestamp)?.dateValue()
        else { return nil }

        // Extract productId from the document's parent path:
        // path: products/{productId}/reviews/{reviewId}
        let pathComponents = doc.reference.path.split(separator: "/")
        let productId: String = pathComponents.count >= 2
            ? String(pathComponents[pathComponents.count - 3])
            : ""

        let productName = productCatalog[productId] ?? "Unknown Product"

        return ReviewItem(
            id: doc.documentID,
            productId: productId,
            productName: productName,
            customerName: data[Firebase.Products.Reviews.customerName] as? String
                          ?? data[Firebase.Products.Reviews.userName] as? String
                          ?? "Customer",
            userId: data[Firebase.Products.Reviews.userId] as? String ?? "",
            rating: min(max(rating, 1), 5),   // clamp to valid range
            comment: comment,
            timestamp: timestamp,
            isHidden: data[Firebase.Products.Reviews.isHidden] as? Bool ?? false
        )
    }

    private func buildRatingDistribution(from ratings: [Int]) -> [RatingBucket] {
        let total = ratings.count
        return (1...5).map { stars in
            let count = ratings.filter { $0 == stars }.count
            return RatingBucket(
                stars: stars,
                count: count,
                percentage: total > 0 ? (Double(count) / Double(total)) * 100 : 0
            )
        }
    }

    /// Groups reviews by calendar week (Monday anchor) and computes avg rating per week.
    private func buildRatingOverTime(from reviews: [(Int, Bool, Date)]) -> [RatingTimePoint] {
        var weekMap: [Date: [Int]] = [:]
        let cal = Calendar.current

        for (rating, _, date) in reviews {
            // Anchor to start of ISO week (Monday)
            let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            guard let weekStart = cal.date(from: components) else { continue }
            weekMap[weekStart, default: []].append(rating)
        }

        return weekMap
            .map { weekStart, ratings in
                RatingTimePoint(
                    weekStart: weekStart,
                    avgRating: Double(ratings.reduce(0, +)) / Double(ratings.count),
                    reviewCount: ratings.count
                )
            }
            .sorted { $0.weekStart < $1.weekStart }
    }
}
