//
//  AddCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cardVM: CardViewModel
    
    @State private var cardNumber: String = ""
    @State private var alertMessage: AlertMessage?
    @State private var isLoading: Bool = false
    var body: some View {
        VStack(spacing: 24) {
            // Important Note Banner
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.blue)
                    Text("Important")
                        .font(.headline)
                    Spacer()
                }
                
                Text("The card owner must add your email **\(UserSession.shared.userEmail ?? "")** as an authorized user before you can add their card.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.accentGold.opacity(0.1))
            .cornerRadius(12)
            
            // Input Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Card Number")
                    .font(.headline)
                
                CustomTextField1(text: $cardNumber,
                                 placeHolder: "Enter 16-digit card number",
                                 keyboardType: .numberPad,
                                 fieldType: .mobileNo,
                                 isAutoCorrect: false, isStarMark: false,
                                 leadingIcon: .username,
                                 trailingView: EmptyView(),
                                 isValidate: .constant(true),
                                 validateText: "",
                                 isAutoCapitalize: .none,
                                 onTextChange: { _ in
                })
                
                Text("\(cardNumber.count)/16 digits")
                    .font(.caption)
                    .foregroundColor(cardNumber.count == 16 ? .green : .secondary)
            }

            CustomCoffeeButton(
                title: isLoading ? "Adding..." : "Add Card",
                isDisabled: cardNumber.count != 16 || isLoading
            ) {
                Task {
                    await addCard()
                }
            }
            
            Spacer()
        }
        .onTapGesture {
            Utilize.hideKeyboard()
        }
        .padding(.horizontal)
        .customNavigationBar("Add Card") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .alert(item: $alertMessage) { alert in
            Alert(
                title: Text(""),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                }
            )
        }
    }

    private func addCard() async {
        isLoading = true
        do {
            try await cardVM.addCard(cardNumber: cardNumber)
            alertMessage = AlertMessage(
                message: "Card added successfully!"
            )
        } catch let error as CardError {
            alertMessage = AlertMessage(
                message: error.localizedDescription
            )
        } catch {
            alertMessage = AlertMessage(
                message: error.localizedDescription
            )
        }
        isLoading = false
    }
}
