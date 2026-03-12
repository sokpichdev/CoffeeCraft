//
//  DashboardHomeViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/12/26.
//

import Foundation
import FirebaseFirestore

@MainActor
final class DashboardHomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var summary: DashboardSummary?
    @Published var liveActivity: [LiveOrderItem] = []
    @Published var selectedPeriod: DashboardPeriod = .today
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private

    private let service = AnalyticsService.shared
    private var liveListener: ListenerRegistration?

    // MARK: - Computed — Revenue for selected period

    var displayRevenue: String {
        guard let summary else { return "$0.00" }
        switch selectedPeriod {
        case .today:  return summary.revenue.todayFormatted
        case .week:   return summary.revenue.thisWeekFormatted
        case .month:  return summary.revenue.thisMonthFormatted
        }
    }

    var displayRevenueLabel: String { selectedPeriod.rawValue }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadSummary() }
        attachLiveListener()
    }

    func onDisappear() {
        liveListener?.remove()
        liveListener = nil
    }

    // MARK: - Load

    func loadSummary() async {
        isLoading = true
        errorMessage = nil
        do {
            summary = try await service.fetchDashboardSummary()
            // Seed liveActivity from summary on first load
            liveActivity = summary?.liveActivity ?? []
        } catch {
            errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
            AppLog.dashboard.error("DashboardHomeViewModel \(error.localizedDescription)")
        }
        isLoading = false
    }

    func refresh() async {
        await loadSummary()
    }

    // MARK: - Live Listener

    private func attachLiveListener() {
        liveListener = service.listenToLiveActivity { [weak self] items in
            Task { @MainActor [weak self] in
                self?.liveActivity = items
            }
        }
    }
}
