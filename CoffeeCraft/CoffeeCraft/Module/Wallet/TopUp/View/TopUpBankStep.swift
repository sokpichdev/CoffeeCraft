//
//  TopUpBankStep.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct TopUpBankStep: View {
    @Binding var selectedBank: BankOption?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your bank")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 10) {
                        ForEach(bankOptions) { bank in
                            BankRow(bank: bank, isSelected: selectedBank?.id == bank.id) {
                                withAnimation(.spring(response: 0.2)) {
                                    selectedBank = bank
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            
            VStack(spacing: 0) {
                Divider()
                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                selectedBank == nil
                                ? Color.gray.opacity(0.4)
                                : Color.accentPrimary
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedBank)
                }
                .disabled(selectedBank == nil)
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
