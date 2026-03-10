//
//  UserRating.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import FirebaseFirestore
import Foundation

// MARK: - UserRating

/// Stored at: products/{productId}/ratings/{userId}
/// Document ID = userId — naturally enforces one rating per user per product.
/// The app reads this doc first on load to know:
///   • whether the current user has already rated (score != nil)
///   • what their previous score was (needed for avg recalculation on edit)
///   • whether they also left a review (reviewId != nil)
struct UserRating: Identifiable, Codable {

    // Document ID is the userId — no @DocumentID needed since we set it explicitly.
    // Using @DocumentID here anyway for consistent Firestore decode behaviour.
    @DocumentID var id: String?

    /// Star score 1–5.
    var score: Int

    /// Firestore document ID of the order used as proof of purchase.
    /// Stored for auditability — admin can trace which order unlocked the rating.
    var orderId: String

    /// Back-reference to the review document (if the user also wrote a review).
    /// nil when the user rated with stars only (no text body).
    /// Used by RatingService.editRating() to locate and update the review doc
    /// without running an extra Firestore query.
    var reviewId: String?

    /// When the rating was first submitted.
    var createdAt: Timestamp

    /// Set when the user edits their rating. nil on first submission.
    var updatedAt: Timestamp?

    // MARK: Computed helpers

    /// True when the user has also written a review alongside their star rating.
    var hasReview: Bool { reviewId != nil }

    /// Human-readable relative timestamp, e.g. "3 days ago".
    var relativeDate: String {
        let date = (updatedAt ?? createdAt).dateValue()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Review

/// Stored at: products/{productId}/reviews/{autoId}
/// Auto-ID document. One per user per product (enforced by RatingService).
/// Review text is optional — a user can submit stars without a body.
/// isHidden allows admin moderation without deleting the document.
struct Review: Identifiable, Codable {
    @DocumentID var id: String?

    /// Firebase UID of the author.
    var userId: String

    /// Display name snapshot captured at write time.
    /// Stored so the review shows the correct name even if the user later
    /// changes their profile name.
    var userName: String

    /// Firestore document ID of the qualifying completed order.
    /// Proof of purchase — written once, never updated on edit.
    var orderId: String

    /// Star score 1–5, denormalized from ratings/{userId}.score.
    /// Kept in sync by RatingService whenever the user edits their rating.
    var rating: Int

    /// Optional headline for the review — mirrors App Store style.
    /// Max 60 characters enforced at the UI layer (RatingInputSheet).
    var title: String?

    /// The written review text. Optional — nil when the user only submitted stars.
    /// Max 280 characters enforced at the UI layer (RatingInputSheet).
    var body: String?

    /// Running count of users who found this review helpful.
    /// Incremented/decremented atomically via FieldValue.increment in RatingService.
    var helpfulCount: Int

    /// Array of userIds who tapped "Helpful".
    /// Used to toggle the button state (already helpful vs not yet).
    /// FieldValue.arrayUnion / arrayRemove keeps this atomic.
    var helpfulBy: [String]

    /// Original submission timestamp.
    var createdAt: Timestamp

    /// Set when the user edits their review body or rating. nil on first submission.
    var updatedAt: Timestamp?

    /// Admin moderation flag. When true, the review is excluded from all
    /// customer-facing queries. The document is retained for audit purposes.
    var isHidden: Bool

    // MARK: - Computed helpers

    /// True when this review has a non-empty title.
    var hasTitle: Bool {
        guard let title else { return false }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// True when this review has a non-empty text body.
    var hasBody: Bool {
        guard let body else { return false }
        return !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether a given user has already marked this review as helpful.
    /// Used to toggle the helpful button fill state in ReviewCard.
    func isHelpful(for userId: String) -> Bool {
        helpfulBy.contains(userId)
    }

    /// Returns the most recent timestamp — updatedAt if the review was edited,
    /// otherwise createdAt. Used for display and pagination sorting.
    var sortTimestamp: Timestamp { updatedAt ?? createdAt }

    /// Human-readable relative date, e.g. "2 hours ago".
    /// Reflects edit time when the review has been updated.
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: sortTimestamp.dateValue(), relativeTo: Date())
    }

    /// Short formatted date string for the review card, e.g. "Mar 10, 2026".
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: sortTimestamp.dateValue())
    }

    /// First letter of the author's name — used for the avatar placeholder circle.
    var avatarInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    /// Truncated preview of the review body — used in compact list contexts.
    /// Returns nil if there's no body.
    var bodyPreview: String? {
        guard let body, hasBody else { return nil }
        let limit = 100
        return body.count > limit ? String(body.prefix(limit)) + "…" : body
    }
}

// MARK: - Review + Factory

extension Review {
    /// Creates a new Review ready to be written to Firestore.
    /// Call this in RatingService.submitReview() to avoid scattering
    /// initialiser logic across the codebase.
    static func create(
        userId: String,
        userName: String,
        orderId: String,
        rating: Int,
        title: String? = nil,
        body: String? = nil
    ) -> Review {
        Review(
            userId: userId,
            userName: userName,
            orderId: orderId,
            rating: rating,
            title: title,
            body: body,
            helpfulCount: 0,
            helpfulBy: [],
            createdAt: Timestamp(date: Date()),
            updatedAt: nil,
            isHidden: false
        )
    }
}
