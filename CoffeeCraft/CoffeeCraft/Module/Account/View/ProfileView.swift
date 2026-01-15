//
//  ProfileView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray)
            
            infoRow("Name", "Sok Pich")
            infoRow("Phone", "+855 12 345 678")
            infoRow("Email", "pich@example.com")
            infoRow("Gender", "Male")
            infoRow("Date of Birth", "10 Oct 1995")
            infoRow("City / Province", "Phnom Penh")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    // coming soon
                }
                .font(.headline)
                .foregroundColor(Color.brown)
            }
        }
    }
    
    func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 8)
    }
}
