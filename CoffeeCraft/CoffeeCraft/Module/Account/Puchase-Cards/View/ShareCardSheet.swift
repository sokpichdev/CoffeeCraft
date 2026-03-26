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
    
    // Local form state — no longer coupled to AuthViewModel
    @State private var email: String = ""
    @State private var emailValidation = FieldValidation()
    
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
                            .foregroundColor(.secondary)
                        CustomTextField1(text: $email,
                                         placeHolder: "Enter User Email",
                                         keyboardType: .emailAddress,
                                         fieldType: .email,
                                         isAutoCorrect: false, isStarMark: true,
                                         leadingIcon: .username,
                                         trailingView: EmptyView(),
                                         isValidate: $emailValidation.isValid,
                                         validateText: emailValidation.message,
                                         isAutoCapitalize: .none,
                                         onTextChange: { _ in
                            validateEmail()
                            if emailValidation.isValid {
                                Task {
                                    do {
                                        foundUserId = try await cardVM.findUserId(byEmail: email) ?? ""
                                    } catch {
                                        AppLog.firestore.error("Error finding user: \(error.localizedDescription)")
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
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Share Button
                    CustomCoffeeButton(title: "Share Card", isDisabled: !emailValidation.isValid || isSharing) {
                        if emailValidation.isValid {
                            shareCard(userID: foundUserId)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onTapGesture {
                Utilize.hideKeyboard()
            }
            .customNavigationBar("Share Card") {
                ToolBarButton(placement: .cancellationAction, buttonType: .text("Cancel")) {
                    dismiss()
                }
            }
        }
        .background(Color.bgPrimary)
    }
    
    private func validateEmail() {
        if email.isEmpty {
            emailValidation = .init(isValid: false, message: "Email is required")
        } else if !email.isValidEmail() {
            emailValidation = .init(isValid: false, message: "Invalid email format")
        } else {
            emailValidation = .init()
        }
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
