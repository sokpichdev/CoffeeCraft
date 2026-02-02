//
//  ToastManagerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/2/26.
//
import SwiftUI

struct ToastManagerView: View {
    @ObservedObject private var toastManager = ToastManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(toastManager.toasts) { toast in
                CoffeeToast(
                    message: toast.message,
                    type: toast.type,
                    duration: toast.duration
                ) {
                    toastManager.dismiss(id: toast.id)
                }
                .id(toast.id) // Force unique instance for each toast
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}
