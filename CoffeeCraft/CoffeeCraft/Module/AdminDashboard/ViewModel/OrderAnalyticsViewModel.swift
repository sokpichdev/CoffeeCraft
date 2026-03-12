//
//  OrderAnalyticsViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 13/03/2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Section Enum

enum OrderAnalyticsSection: String, CaseIterable, Identifiable {
    case queue   = "Queue"
    case history = "History"
    case funnel  = "Funnel"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .queue:   return "flame.fill"
        case .history: return "clock.arrow.circlepath"
        case .funnel:  return "chart.bar.xaxis"
        }
    }
}

@MainActor
final class OrderAnalyticsViewModel: ObservableObject {

    // MARK: - Section

    @Published var selectedSection: OrderAnalyticsSection = .queue

    // MARK: - Queue

    @Published var queueItems: [OrderQueueItem] = []
    @Published var isUpdatingStatus: Set<String> = []   // prevents double-tap

    // MARK: - History

    @Published var historyItems: [OrderQueueItem] = []
    @Published var filter = OrderHistoryFilter()
    @Published var isLoadingHistory = false
    @Published var isLoadingMoreHistory = false
    @Published var canLoadMoreHistory = true

    // MARK: - Funnel

    @Published var funnelData: OrderFunnelData = .empty
    @Published var isLoadingFunnel = false

    // MARK: - Private

    private let service = AnalyticsService.shared
    private var queueListener: ListenerRegistration?
    private var historyLastDoc: DocumentSnapshot?

    // MARK: - Lifecycle

    func onAppear() {
        attachQueueListener()
        Task { await loadHistory() }
        Task { await loadFunnel() }
    }

    func onDisappear() {
        queueListener?.remove()
        queueListener = nil
    }

    // MARK: - Queue

    private func attachQueueListener() {
        queueListener = service.listenToOrderQueue { [weak self] items in
            Task { @MainActor [weak self] in
                self?.queueItems = items
            }
        }
    }

    /// Advances an order to the next status.
    /// Guarded by `isUpdatingStatus` to prevent double-taps.
    func advanceStatus(for item: OrderQueueItem) async {
        guard let next = item.nextStatus,
              !isUpdatingStatus.contains(item.id) else { return }

        isUpdatingStatus.insert(item.id)
        do {
            try await service.updateOrderStatus(orderId: item.id, to: next)
            // Queue listener auto-refreshes — no manual reload needed
        } catch {
            AlertManager.shared.showError(
                title: "Update Failed",
                message: error.localizedDescription
            )
        }
        isUpdatingStatus.remove(item.id)
    }

    // MARK: - History

    func loadHistory() async {
        isLoadingHistory = true
        historyLastDoc = nil
        canLoadMoreHistory = true

        do {
            let page = try await service.fetchOrderHistory(filter: filter)
            historyItems = page.items
            historyLastDoc = page.lastDocument
            canLoadMoreHistory = page.hasMore
        } catch {
            AppLog.dashboard.error("OrderAnalyticsViewModel history \(error.localizedDescription)")
        }
        isLoadingHistory = false
    }

    func loadMoreHistory() async {
        guard canLoadMoreHistory,
              !isLoadingMoreHistory,
              !isLoadingHistory,
              let cursor = historyLastDoc else { return }

        isLoadingMoreHistory = true
        do {
            let page = try await service.fetchMoreOrderHistory(filter: filter, after: cursor)
            historyItems.append(contentsOf: page.items)
            historyLastDoc = page.lastDocument
            canLoadMoreHistory = page.hasMore
        } catch {
            AppLog.dashboard.error("loadMoreHistory \(error.localizedDescription)")
        }
        isLoadingMoreHistory = false
    }

    func applyFilter() async {
        await loadHistory()
    }

    // MARK: - Funnel

    func loadFunnel() async {
        isLoadingFunnel = true
        do {
            funnelData = try await service.fetchOrderFunnel()
        } catch {
            AppLog.dashboard.error("OrderAnalyticsViewModel funnel \(error.localizedDescription)")
        }
        isLoadingFunnel = false
    }
}
