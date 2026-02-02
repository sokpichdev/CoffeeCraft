//
//  ToastManagerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/2/26.
//
import SwiftUI

struct ToastManagerView: View {
    @ObservedObject private var toastManager = ToastManager.shared
    let position: ToastPosition
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(filteredToasts) { toast in
                CoffeeToast(
                    message: toast.message,
                    type: toast.type,
                    duration: toast.duration
                ) {
                    toastManager.dismiss(id: toast.id)
                }
                .id(toast.id)
                .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(position == .top ? .top : .bottom, position == .bottom ? 50 : 30)
    }
    
    private var filteredToasts: [ToastItem] {
        toastManager.toasts.filter { $0.position == position }
    }
}
