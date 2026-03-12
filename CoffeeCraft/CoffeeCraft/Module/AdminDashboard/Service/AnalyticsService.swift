//
//  AnalyticsService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import FirebaseFirestore
import Foundation

// MARK: - Analytics Service

/// Singleton service responsible for all admin analytics queries.
/// Phase 8.1 covers: dashboard summary, live order feed.
extension AnalyticsService {

    // MARK: - Dashboard Summary

    /// Fetches all data needed for the Dashboard Home screen.
    /// Runs queries in parallel using async task group for performance.
    func fetchDashboardSummary() async throws -> DashboardSummary {
        async let revenue = fetchRevenueSummary()
        async let orders  = fetchOrderSummary()
        async let customers = fetchCustomerSummary()
        async let liveActivity = fetchLiveActivity()

        return try await DashboardSummary(
            revenue: revenue,
            orders: orders,
            customers: customers,
            liveActivity: liveActivity
        )
    }

    // MARK: - Revenue

    private func fetchRevenueSummary() async throws -> RevenueSummary {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: todayStart)!
        let monthStart = Calendar.current.date(byAdding: .day, value: -29, to: todayStart)!

        async let todayRevenue = revenueInRange(from: todayStart, to: now)
        async let weekRevenue = revenueInRange(from: weekStart, to: now)
        async let monthRevenue = revenueInRange(from: monthStart, to: now)

        return try await RevenueSummary(
            today: todayRevenue,
            thisWeek: weekRevenue,
            thisMonth: monthRevenue
        )
    }

    private func revenueInRange(from start: Date, to end: Date) async throws -> Double {
        let snapshot = try await db.collection("orders")
            .whereField("status", isEqualTo: "Completed")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
            .whereField("timestamp", isLessThanOrEqualTo: Timestamp(date: end))
            .getDocuments()

        return snapshot.documents.reduce(0.0) { sum, doc in
            sum + (doc.data()["totalPrice"] as? Double ?? 0)
        }
    }

    // MARK: - Orders

    private func fetchOrderSummary() async throws -> OrderSummary {
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let yesterdayStart = Calendar.current.date(byAdding: .day, value: -1, to: todayStart)!

        async let todaySnapshot = db.collection("orders")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: todayStart))
            .getDocuments()

        async let yesterdaySnapshot = db.collection("orders")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: yesterdayStart))
            .whereField("timestamp", isLessThan: Timestamp(date: todayStart))
            .getDocuments()

        async let activeSnapshot = db.collection("orders")
            .whereField("status", in: ["Pending", "Preparing"])
            .getDocuments()

        let (today, yesterday, active) = try await (todaySnapshot, yesterdaySnapshot, activeSnapshot)

        return OrderSummary(
            todayCount: today.documents.count,
            yesterdayCount: yesterday.documents.count,
            activeCount: active.documents.count
        )
    }

    // MARK: - Customers

    private func fetchCustomerSummary() async throws -> CustomerSummary {
        let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: Date())!

        async let newUsersSnapshot = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: weekStart))
            .getDocuments()

        async let totalUsersSnapshot = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .getDocuments()

        let (newUsers, totalUsers) = try await (newUsersSnapshot, totalUsersSnapshot)

        return CustomerSummary(
            newThisWeek: newUsers.documents.count,
            totalCount: totalUsers.documents.count
        )
    }

    // MARK: - Live Activity Feed

    /// Returns the 10 most recent orders across all statuses.
    func fetchLiveActivity() async throws -> [LiveOrderItem] {
        let snapshot = try await db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> LiveOrderItem? in
            let data = doc.data()
            guard
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                let totalPrice = data["totalPrice"] as? Double,
                let status = data["status"] as? String
            else { return nil }

            let items = data["items"] as? [[String: Any]] ?? []

            return LiveOrderItem(
                id: doc.documentID,
                customerName: data["customerName"] as? String ?? "Customer",
                totalPrice: totalPrice,
                status: status,
                timestamp: timestamp,
                itemCount: items.count
            )
        }
    }

    // MARK: - Real-time Listener

    /// Attaches a snapshot listener to the 10 most recent orders.
    /// Call `remove()` on the returned listener handle when the view disappears.
    func listenToLiveActivity(onChange: @escaping ([LiveOrderItem]) -> Void) -> ListenerRegistration {
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot else { return }
                let items = snapshot.documents.compactMap { doc -> LiveOrderItem? in
                    let data = doc.data()
                    guard
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                        let totalPrice = data["totalPrice"] as? Double,
                        let status = data["status"] as? String
                    else { return nil }
                    let items = data["items"] as? [[String: Any]] ?? []
                    return LiveOrderItem(
                        id: doc.documentID,
                        customerName: data["customerName"] as? String ?? "Customer",
                        totalPrice: totalPrice,
                        status: status,
                        timestamp: timestamp,
                        itemCount: items.count
                    )
                }
                onChange(items)
            }
    }
}
