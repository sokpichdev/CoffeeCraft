//
//  SalesAnalyticsViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/03/2026.
//

import Foundation

@MainActor
final class SalesAnalyticsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var analyticsData: SalesAnalyticsData?
    @Published var selectedPeriod: SalesPeriod = .week
    @Published var isLoading: Bool = false

    // MARK: - Private

    private let service = AnalyticsService.shared

    // MARK: - Computed — Chart helpers

    /// Max revenue value across all daily points — used to set chart y-axis domain.
    var revenueChartMax: Double {
        let max = analyticsData?.dailyRevenue.map(\.revenue).max() ?? 0
        return max == 0 ? 100 : max * 1.2 // 20% headroom so the peak isn't clipped
    }

    var hasData: Bool {
        (analyticsData?.summary.totalOrders ?? 0) > 0
    }

    /// Highest order count in peak hours — used to normalise heatmap cell colour.
    var peakHourMax: Int {
        analyticsData?.peakHours.map(\.orderCount).max() ?? 1
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadAnalytics() }
    }

    // MARK: - Load

    func loadAnalytics() async {
        isLoading = true
        do {
            analyticsData = try await service.fetchSalesAnalytics(for: selectedPeriod)
        } catch {
            AlertManager.shared.showConfirmation(
                title: "Failed to load analytics",
                message: error.localizedDescription,
                type: .error,
                confirmTitle: "Retry",
                cancelTitle: "Dismiss",
                onConfirm: { Task { await self.loadAnalytics() } }
            )
            AppLog.dashboard.error("SalesAnalyticsViewModel \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// Called when the period picker changes — reloads from Firestore for the new range.
    func periodChanged() async {
        await loadAnalytics()
    }
}
