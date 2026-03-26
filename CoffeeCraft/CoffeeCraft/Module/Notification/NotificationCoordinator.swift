//
//  NotificationCoordinator.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//
import SwiftUI
import Combine

@MainActor
class NotificationCoordinator: ObservableObject {
    static let shared = NotificationCoordinator()

    @Published var selectedOrderId: String?
    @Published var shouldNavigateToOrders = false

    private init() {
        setupNotificationObserver()
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNavigateToOrder),
            name: Notification.Name("NavigateToOrder"),
            object: nil
        )
    }

    @objc private func handleNavigateToOrder(_ notification: Notification) {
        guard let orderId = notification.userInfo?["orderId"] as? String else { return }
        AppLog.firestore.debug("🔔 NotificationCoordinator: Navigating to order: \(orderId)")
        Task { @MainActor in
            self.selectedOrderId = orderId
            self.shouldNavigateToOrders = true
        }
    }

    func clearNavigation() {
        selectedOrderId = nil
        shouldNavigateToOrders = false
    }
}
