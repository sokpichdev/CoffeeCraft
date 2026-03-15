//
//  MapAnalytics.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.
//

import Foundation

// MARK: - MapAnalytics

enum MapAnalytics {

    // MARK: - Branch Selected

    /// Fired when the user taps a branch pin or strip card.
    static func branchSelected(branchId: String, branchName: String, distanceKm: Double?) {
        let km = distanceKm.map { String(format: "%.2f", $0) } ?? "unknown"
        AppLog.firestore.info("""
            [Analytics] branch_selected \
            — id: \(branchId), name: \(branchName), distance_km: \(km)
            """)

        // 🔌 Wire Firebase Analytics here when SDK is added:
        // Analytics.logEvent("branch_selected", parameters: [
        //     "branch_id":    branchId,
        //     "branch_name":  branchName,
        //     "distance_km":  distanceKm ?? -1
        // ])
    }

    // MARK: - Order Started from Branch

    /// Fired when the user taps "Order from Here" in BranchDetailSheet.
    static func branchOrderStarted(branchId: String, branchName: String) {
        AppLog.firestore.info("""
            [Analytics] branch_order_started \
            — id: \(branchId), name: \(branchName)
            """)

        // Analytics.logEvent("branch_order_started", parameters: [
        //     "branch_id":   branchId,
        //     "branch_name": branchName
        // ])
    }

    // MARK: - Filter Applied

    /// Fired when a filter chip is toggled on.
    static func filterApplied(_ filter: MapFilter) {
        AppLog.firestore.info("[Analytics] map_filter_applied — filter: \(filter.rawValue)")

        // Analytics.logEvent("map_filter_applied", parameters: [
        //     "filter": filter.rawValue
        // ])
    }

    // MARK: - Search Used

    /// Fired when the user types a non-empty query and results are returned.
    static func mapSearched(query: String, resultCount: Int) {
        AppLog.firestore.info(
            "[Analytics] map_searched — query: \"\(query)\", results: \(resultCount)"
        )

        // Analytics.logEvent("map_searched", parameters: [
        //     "query":        query,
        //     "result_count": resultCount
        // ])
    }
}
