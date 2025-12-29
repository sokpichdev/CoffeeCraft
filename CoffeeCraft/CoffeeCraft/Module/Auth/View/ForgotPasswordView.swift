//
//  ForgotPasswordView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/13/25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Enter the email address associated with your account to receive a password reset link.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    CustomTextField1(text: $email,
                                     placeHolder: "Email Address",
                                     keyboardType: .emailAddress,
                                     fieldType: .email,
                                     isAutoCorrect: false, isStarMark: true,
                                     leadingIcon: .username,
                                     trailingView: EmptyView(),
                                     isValidate: .constant(true), // change later
                                     validateText: "Error Text",
                                     isAutoCapitalize: .none,
                                     onTextChange: { _ in
        //                 // func to check
                    })
                    .padding(.horizontal)

                    Button {
                        Task {
                            isLoading = true
                            do {
                                try await authVM.sendPasswordReset(email: email)
                                alertMessage = "Password reset link sent to \(email)."
                                showAlert = true
                            } catch {
                                alertMessage = "Error: \(error.localizedDescription)"
                                showAlert = true
                            }
                            isLoading = false
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Send Reset Link").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .brown.opacity(0.4), radius: 6, y: 4)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading || email.isEmpty)
                }
                .padding(.top, 40)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Password Reset", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("sent to") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}
