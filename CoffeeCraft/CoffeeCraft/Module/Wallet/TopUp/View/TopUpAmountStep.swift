//
//  TopUpAmountStep.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct TopUpAmountStep: View {
    
    @Binding var selectedAmount: Double?
    @Binding var customInput: String
    let onContinue: () -> Void
    
    private let presetAmounts: [Double] = [5, 10, 20, 50, 100]
    
    private var resolvedAmount: Double? {
        if let selectedAmount { return selectedAmount }
        if let value = Double(customInput), value > 0 { return value }
        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentPrimary.opacity(0.1))
                            .frame(width: 72, height: 72)
                        
                        Circle()
                            .strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1.5)
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.accentPrimary)
                    }
                    
                    Text("Top Up Wallet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Select an amount to add to your balance")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Amount Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Amount")
                        .font(.headline)
                        .foregroundColor(Color.textPrimary)
                    
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(presetAmounts, id: \.self) { amount in
                            CoffeeAmountPill(
                                amount: amount,
                                isSelected: selectedAmount == amount && customInput.isEmpty
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedAmount = amount
                                    customInput = ""
                                }
                            }
                        }
                    }
                    
                    CustomTopupAmountField(input: $customInput)
                        .onChange(of: customInput) { _, _ in
                            selectedAmount = nil
                        }
                }
                .padding(.horizontal, 20)
                
                // Summary Card
                if let amount = resolvedAmount {
                    summaryCard(amount: amount)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                }
                
                Spacer(minLength: 40)
            }
        }
        
        // Bottom Action
        VStack(spacing: 0) {
            Divider()
                .overlay(Color.border)
            Button {
                onContinue()
            } label: {
                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.headline)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color.bgPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            resolvedAmount == nil
                            ? Color.textMuted.opacity(0.35)
                            : Color.accentPrimary
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: resolvedAmount)
            }
            .disabled(resolvedAmount == nil)
            .padding(20)
        }
        .background(Color.bgSecondary)
    }
    
    private func summaryCard(amount: Double) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Amount to add")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("$\(String(format: "%.2f", amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
                .overlay(Color.border)
                .padding(.horizontal, 16)
            
            HStack {
                Text("Payment method")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("Bank Transfer")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.accentPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}
