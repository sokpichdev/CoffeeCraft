//
//  ShareCardSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/27/26.
//

import SwiftUI

struct ShareCardSheet: View {
    @EnvironmentObject var cardVM: CardViewModel
    @Environment(\.dismiss) private var dismiss
    
    let card: LoyaltyCard
    
    @State private var enteredUserId = ""
    @State private var isSharing = false
    @State private var shareError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Card Preview
                FlippableCardView(card: card, width: UIScreen.main.bounds.width - 32)
                    .padding(.top, 10)
                
                // Share Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Share with")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        CustomProductTextField(title: "Enter User ID", text: $enteredUserId, icon: "person.text.rectangle")
                            .disabled(isSharing)
                    }
                    
                    // Error Message
                    if let error = shareError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Share Button
                    Button {
                        shareCard()
                    } label: {
                        HStack {
                            if isSharing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Share Card")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(enteredUserId.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(enteredUserId.isEmpty || isSharing)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Share Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func shareCard() {
        guard !enteredUserId.isEmpty else { return }
        
        isSharing = true
        shareError = nil
        
        Task {
            do {
                try await cardVM.shareCard(card, with: enteredUserId)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    shareError = error.localizedDescription
                    isSharing = false
                }
            }
        }
    }
}
