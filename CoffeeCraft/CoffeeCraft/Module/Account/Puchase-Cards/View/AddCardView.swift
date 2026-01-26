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

    var body: some View {
        VStack(spacing: 24) {
            TextField("Enter 16-digit card number", text: $cardNumber)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

            Button {
                Task {
                    await addCard()
                }
            } label: {
                if cardVM.isLoading {
                    ProgressView()
                } else {
                    Text("Add Card")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brown)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(cardNumber.isEmpty)

            Spacer()
        }
        .customNavigationBar("Add Card") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .alert(item: $alertMessage) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func addCard() async {
        do {
            try await cardVM.addCard(cardNumber: cardNumber)
            dismiss()
        } catch let error as CardError {
            alertMessage = AlertMessage(message: error.localizedDescription)
        } catch {
            alertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
}
