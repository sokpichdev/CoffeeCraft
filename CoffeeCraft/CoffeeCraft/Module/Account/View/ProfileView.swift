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
        ScrollView {
            VStack(spacing: 28) {
                profileHeader
                
                VStack(spacing: 0) {
                    infoRow("Name", "Sok Pich", icon: "person.fill")
                    Divider().padding(.leading, 50)
                    infoRow("Phone", "+855 77 742 462", icon: "phone.fill")
                    Divider().padding(.leading, 50)
                    infoRow("Email", "pichsok016@example.com", icon: "envelope.fill")
                    Divider().padding(.leading, 50)
                    infoRow("Gender", "Male", icon: "figure.stand")
                    Divider().padding(.leading, 50)
                    infoRow("Date of Birth", "17 Sep 2001", icon: "calendar")
                    Divider().padding(.leading, 50)
                    infoRow("City / Province", "Phnom Penh", icon: "mappin.circle.fill")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // coming soon
                } label: {
                    HStack(spacing: 6) {
                        Text("Edit")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                    }
                    .foregroundStyle(Color.brown)
                }
            }
        }
    }
    
    var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brown, Color.brown.opacity(0.75), Color.brown.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: Color.brown.opacity(0.4), radius: 12, y: 6)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 6) {
                Text("Sok Pich")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Coffee Enthusiast")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    func infoRow(_ title: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
    }
}
