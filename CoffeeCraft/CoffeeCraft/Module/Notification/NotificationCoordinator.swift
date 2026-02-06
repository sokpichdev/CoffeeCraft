//
//  NotificationCoordinator.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//
import SwiftUI
import Combine

class NotificationCoordinator: ObservableObject {
    static let shared = NotificationCoordinator()
    
    // Published property that views can observe
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
        if let orderId = notification.userInfo?["orderId"] as? String {
            print("🔔 NotificationCoordinator: Navigating to order: \(orderId)")
            DispatchQueue.main.async {
                self.selectedOrderId = orderId
                self.shouldNavigateToOrders = true
            }
        }
    }
    
    func clearNavigation() {
        selectedOrderId = nil
        shouldNavigateToOrders = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
