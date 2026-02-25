//
//  LoginPromptView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/25/26.
//
import SwiftUI

struct LoginPromptView: View {
    var onSignInTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)

            Text("Sign in to continue")
                .font(.title3)

            Text("Create an account or log in to place orders, track your history, and earn rewards.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            CustomCoffeeButton(title: "Sign In / Create Account") {
                onSignInTapped()
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}
