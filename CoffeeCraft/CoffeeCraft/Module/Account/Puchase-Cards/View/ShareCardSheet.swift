//
//  ShareCardSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/27/26.
//

import SwiftUI

struct ShareCardSheet: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var cardVM: CardViewModel
    @Environment(\.dismiss) private var dismiss
    
    let card: LoyaltyCard
    
    @State private var isSharing = false
    @State private var shareError: String?
    @State private var foundUserId: String = ""
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
//                        CustomProductTextField(title: "Enter User ID", text: $enteredUserEmail, icon: "person.text.rectangle")
//                            .disabled(isSharing)
                        CustomTextField1(text: $authVM.email,
                                         placeHolder: "Enter User Email",
                                         keyboardType: .emailAddress,
                                         fieldType: .email,
                                         isAutoCorrect: false, isStarMark: true,
                                         leadingIcon: .username,
                                         trailingView: EmptyView(),
                                         isValidate: $authVM.emailValidation.isValid,
                                         validateText: authVM.emailValidation.message,
                                         isAutoCapitalize: .none,
                                         onTextChange: { _ in
                            authVM.validateEmail()
                            if authVM.emailValidation.isValid {
                                Task {
                                    do {
                                        foundUserId = try await cardVM.findUserId(byEmail: authVM.email) ?? ""
                                    } catch {
                                        print("Error finding user: \(error)")
                                        foundUserId = ""
                                    }
                                }
                            }
                        }
                        )
                    }
                    
                    // Error Message
                    if let error = shareError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Share Button
                    CustomCoffeeButton(title: "Share Card", isDisabled: !authVM.emailValidation.isValid || isSharing) {
                        if authVM.emailValidation.isValid {
                            shareCard(userID: foundUserId)
                        }
                    }
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
    
    private func shareCard(userID: String) {
        guard !userID.isEmpty else { return }
        
        isSharing = true
        shareError = nil
        
        Task {
            do {
                try await cardVM.shareCard(card, with: userID)
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
