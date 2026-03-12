//
//  TopUpView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 03/03/2026.
//

import SwiftUI

struct TopUpView: View {
    
    @ObservedObject var walletVM: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: TopUpStep = .amount
    @State private var selectedAmount: Double?
    @State private var customInput: String = ""
    @State private var selectedBank: BankOption?
    
    private var resolvedAmount: Double? {
        if let selectedAmount { return selectedAmount }
        if let value = Double(customInput), value > 0 { return value }
        return nil
    }
    
    enum TopUpStep {
        case amount, bank, checkout
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: stepProgress, total: 1.0)
                .tint(Color.accentPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .background(Color.bgSecondary)
            
            switch currentStep {
            case .amount:
                TopUpAmountStep(
                    selectedAmount: $selectedAmount,
                    customInput: $customInput
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        currentStep = .bank
                    }
                }
                
            case .bank:
                TopUpBankStep(selectedBank: $selectedBank) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        currentStep = .checkout
                    }
                }
                
            case .checkout:
                if let bank = selectedBank, let amount = resolvedAmount {
                    TopUpCheckoutStep(
                        walletVM: walletVM,
                        bank: bank,
                        usdAmount: amount
                    ) {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.bgPrimary)
        .customNavigationBar(navigationTitle) {
            ToolBarButton.back {
                handleBack()
            }
        }
    }
    
    private var stepProgress: Double {
        switch currentStep {
        case .amount: return 0.33
        case .bank: return 0.66
        case .checkout: return 1.0
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .amount: return "Top Up"
        case .bank: return "Payment Method"
        case .checkout: return "Checkout"
        }
    }
    
    private func handleBack() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            switch currentStep {
            case .amount: dismiss()
            case .bank: currentStep = .amount
            case .checkout: currentStep = .bank
            }
        }
    }
}
