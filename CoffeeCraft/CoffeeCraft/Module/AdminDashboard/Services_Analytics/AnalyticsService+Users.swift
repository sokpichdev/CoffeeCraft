//
//  AnalyticsService+Users.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import FirebaseFirestore
import Foundation

// MARK: - AnalyticsService — User Management (Phase 8.5)

extension AnalyticsService {

    // MARK: - User List (Paginated)

    /// Fetches the first page of customers sorted by newest join date.
    /// Does NOT include totalOrders/totalSpent — call `enrichUsers` after.
    func fetchUserList(searchText: String = "",
                       pageSize: Int = 20) async throws -> UserListPage {
        let query: Query = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize + 1)

        let snapshot = try await query.getDocuments()
        var items = snapshot.documents.compactMap(mapToUserStatItem)

        // Client-side search — Firestore has no native full-text support.
        // For production at scale, consider Algolia or pre-tokenised name arrays.
        if !searchText.isEmpty {
            let term = searchText.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(term) ||
                $0.email.lowercased().contains(term)
            }
        }

        let hasMore = snapshot.documents.count > pageSize
        return UserListPage(
            items: Array(items.prefix(pageSize)),
            lastDocument: snapshot.documents.last,
            hasMore: hasMore
        )
    }

    /// Fetches the next page after a cursor.
    func fetchMoreUsers(after cursor: DocumentSnapshot,
                        searchText: String = "",
                        pageSize: Int = 20) async throws -> UserListPage {
        let snapshot = try await db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: cursor)
            .limit(to: pageSize + 1)
            .getDocuments()

        var items = snapshot.documents.compactMap(mapToUserStatItem)

        if !searchText.isEmpty {
            let term = searchText.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(term) ||
                $0.email.lowercased().contains(term)
            }
        }

        let hasMore = snapshot.documents.count > pageSize
        return UserListPage(
            items: Array(items.prefix(pageSize)),
            lastDocument: snapshot.documents.last,
            hasMore: hasMore
        )
    }

    // MARK: - Background Enrichment

    func enrichUsersWithOrderStats(
        userIds: [String]
    ) async -> [String: (Int, Double)] {
        await withTaskGroup(of: (String, Int, Double).self) { group in
            for userId in userIds {
                group.addTask {
                    let ordersQuery = self.db.collection("orders")
                        .whereField("userId", isEqualTo: userId)
                        .whereField("status", isEqualTo: OrderStatus.completed.rawValue)

                    // Isolated try/catch — a sum failure does not zero the count.
                    let count: Int
                    do {
                        let result = try await ordersQuery
                            .count
                            .getAggregation(source: .server)
                        count = Int(truncating: result.count)
                    } catch {
                        AppLog.dashboard.error("[enrichUsers] count ❌ \(userId): \(error.localizedDescription)")
                        count = 0
                    }
                    
                    let spent: Double
                    do {
                        let sumField = AggregateField.sum("totalPrice")
                        let result = try await ordersQuery
                            .aggregate([sumField])
                            .getAggregation(source: .server)
                        spent = result.get(sumField) as? Double ?? 0
                    } catch {
                        AppLog.dashboard.error("[enrichUsers] sum ❌ \(userId): \(error.localizedDescription) — falling back to getDocuments()")
                        // Fallback: fetch at most 200 docs and sum client-side.
                        // Bounded cost; works on any SDK version.
                        let snap = try? await ordersQuery.limit(to: 200).getDocuments()
                        spent = snap?.documents.reduce(0.0) {
                            $0 + ($1.data()["totalPrice"] as? Double ?? 0)
                        } ?? 0
                    }

                    return (userId, count, spent)
                }
            }

            var result: [String: (Int, Double)] = [:]
            for await (userId, count, spent) in group {
                result[userId] = (count, spent)
            }
            return result
        }
    }

    // MARK: - User Detail

    /// Fetches everything needed for the User Detail screen in parallel:
    ///   - User doc (for fcmToken, any extra fields)
    ///   - Last 10 orders (all statuses)
    ///   - Wallet balance
    func fetchUserDetail(userId: String, base: UserStatItem) async throws -> UserDetailData {
        async let userDocFetch = db.collection("users").document(userId).getDocument()
        async let ordersFetch = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments()
        async let walletFetch = db.collection("wallets").document(userId).getDocument()

        let (userDoc, ordersSnap, walletDoc) = try await (userDocFetch, ordersFetch, walletFetch)

        let fcmToken = userDoc.data()?["fcmToken"] as? String

        let recentOrders: [UserOrderItem] = ordersSnap.documents.compactMap { doc in
            let data = doc.data()
            guard
                let ts = (data["timestamp"] as? Timestamp)?.dateValue(),
                let totalPrice = data["totalPrice"] as? Double,
                let status = data["status"] as? String
            else { return nil }

            let items = data["items"] as? [[String: Any]] ?? []
            return UserOrderItem(
                id: doc.documentID,
                totalPrice: totalPrice,
                status: status,
                timestamp: ts,
                itemCount: items.count
            )
        }

        let walletBalance = walletDoc.data()?["balance"] as? Double ?? 0

        return UserDetailData(
            user: base,
            recentOrders: recentOrders,
            walletBalance: walletBalance,
            fcmToken: fcmToken
        )
    }

    // MARK: - Push Notification

    /// Sends a push notification to a specific user via FCM.
    ///
    /// ⚠️  This requires a Cloud Function or a server-side endpoint that holds
    /// the FCM server key — sending directly from the client is deprecated by Google.
    ///
    /// Implementation options:
    ///   A) Firebase Cloud Function triggered by a Firestore write to
    ///      `notifications/{userId}/queue/{id}` — safest, no key on client.
    ///   B) Your own backend endpoint (POST /send-notification).
    ///
    /// This method writes a notification document to Firestore.
    /// A Cloud Function watches that collection and calls FCM.
    func sendNotificationToUser(userId: String,
                                title: String,
                                body: String) async throws {
        let notifData: [String: Any] = [
            "userId": userId,
            "title": title,
            "body": body,
            "sentAt": FieldValue.serverTimestamp(),
            "sentBy": "manager",
            "status": "pending"   // Cloud Function updates to "sent" / "failed"
        ]

        try await db.collection("notifications")
            .document(userId)
            .collection("queue")
            .addDocument(data: notifData)

        AppLog.dashboard.info("Notification queued for userId: \(userId)")
    }

    // MARK: - Shared Mapper

    private func mapToUserStatItem(_ doc: DocumentSnapshot) -> UserStatItem? {
        let data = doc.data() ?? [:]
        // `name` is the only true required field — `createdAt` is optional so
        // accounts registered before the analytics fix still appear in the list.
        guard let name = data["name"] as? String else { return nil }

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)

        return UserStatItem(
            id: doc.documentID,
            name: name,
            email: data["email"] as? String ?? "",
            joinDate: createdAt,
            loyaltyPoints: data["loyaltyPoints"] as? Int ?? 0
        )
    }
}
