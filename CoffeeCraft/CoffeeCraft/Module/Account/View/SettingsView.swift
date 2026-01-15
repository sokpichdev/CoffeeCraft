//
//  SettingsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            Section {
                row("Account Settings")
                row("Face ID & PIN")
            }
            
            Section {
                row("Connected Accounts")
            }
            
            Section {
                row("Appearance")
                row("Languages")
            }
            
            Section {
                row("FAQs")
                row("Terms & Conditions")
                row("About Us")
            }
            
            Section {
                row("Share the App")
                row("Write a Review")
            }
            
            Section {
                Button("Logout") {}
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
    }
    
    func row(_ title: String) -> some View {
        Button(title) {
            // coming soon
        }
    }
}
