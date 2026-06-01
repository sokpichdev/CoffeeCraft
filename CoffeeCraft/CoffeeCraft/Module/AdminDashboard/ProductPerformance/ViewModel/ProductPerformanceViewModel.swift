//
//  ProductPerformanceViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import Foundation

@MainActor
final class ProductPerformanceViewModel: ObservableObject {

    // MARK: - Published State

    @Published var performanceData: ProductPerformanceData?
    @Published var selectedRange: DateRange = .last30Days // default 30 days for richer data
    @Published var isLoading: Bool = false

    // MARK: - Private

    private let service = AnalyticsService.shared

    // MARK: - Computed

    var hasData: Bool { performanceData?.hasData ?? false }

    /// Max units sold across all products — used to scale the bar chart y-axis.
    var maxUnitsSold: Int {
        performanceData?.topProducts.map(\.unitsSold).max() ?? 1
    }

    /// Max revenue across categories — used to anchor the donut annotation.
    var totalRevenue: Double {
        performanceData?.totalRevenue ?? 0
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadPerformance() }
    }

    // MARK: - Load

    func loadPerformance() async {
        isLoading = true
        do {
            performanceData = try await service.fetchProductPerformance(range: selectedRange)
        } catch {
            AlertManager.shared.showConfirmation(
                title: "Failed to load product data",
                message: error.localizedDescription,
                type: .error,
                confirmTitle: "Retry",
                cancelTitle: "Dismiss",
                onConfirm: { Task { await self.loadPerformance() } }
            )
            AppLog.dashboard.error("ProductPerformanceViewModel \(error.localizedDescription)")
        }
        isLoading = false
    }

}
