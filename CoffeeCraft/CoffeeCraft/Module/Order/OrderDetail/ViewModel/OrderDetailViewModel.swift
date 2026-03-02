//
//  OrderDetailViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OrderDetailViewModel: ObservableObject {
    @Published var order: Order
    @Published var userName: String = "Loading..."
    @Published var isLoadingUser = true
    @Published var isUpdatingStatus = false
    @Published var lastStatusUpdate: String?
    
    private let db = Firestore.firestore()
    private var orderListener: ListenerRegistration?
    private var hasAppeared = false
    
    init(order: Order) {
        self.order = order
    }
    
    deinit {
        orderListener?.remove()
    }
    
    func startListening(orderId: String) {
        guard !hasAppeared else { return }
        hasAppeared = true
        
        // Listen to order changes in real-time
        orderListener = db.collection("orders")
            .document(orderId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    AppLog.order.error("❌ OrderDetail listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                do {
                    let updatedOrder = try snapshot.data(as: Order.self)
                    
                    // Check if status changed
                    if updatedOrder.status != self.order.status {
                        self.lastStatusUpdate = updatedOrder.status
                        ToastManager.shared.showTop(message: "Order is now \(updatedOrder.status ?? "").", type: .success)
                        
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                    
                    self.order = updatedOrder
                    AppLog.order.debug("✅ OrderDetail id: \(updatedOrder.id ?? "nil") status: \(updatedOrder.status ?? "")")
                    AppLog.printItem(updatedOrder, label: "OrderDetail id: \(updatedOrder.id ?? "nil")")
                } catch {
                    AppLog.order.error("❌ Failed to decode order: \(error.localizedDescription)")
                }
            }
    }
    
    func fetchUserInfo(userId: String) {
        isLoadingUser = true
        
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    defer { self.isLoadingUser = false }
                    
                    if let error = error {
                        AppLog.order.error("❌ Failed to fetch user: \(error.localizedDescription)")
                        self.userName = "Unknown User"
                        return
                    }
                    
                    if let data = snapshot?.data(),
                       let name = (data["name"] as? String) {
                        self.userName = name
                    } else {
                        self.userName = "User #\(userId.prefix(6))"
                    }
                }
            }
    }
    
    func updateOrderStatus(to status: String) async {
        guard let orderId = order.id else { return }
        
        isUpdatingStatus = true
        defer { isUpdatingStatus = false }
        
        do {
            try await db.collection("orders")
                .document(orderId)
                .updateData(["status": status])
            
            AppLog.order.debug("✅ updateOrderStatus — \(orderId) → \(status)")
            // The real-time listener will pick up the change and update `order` automatically
        } catch {
            AppLog.order.error("❌ updateOrderStatus error: \(error.localizedDescription)")
            AlertManager.shared.showError(
                title: "Error updating status",
                message: error.localizedDescription
            )
        }
    }
    
    func stopListening() {
        orderListener?.remove()
        orderListener = nil
    }
}
