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
                    infoRow("Phone", "+855 12 345 678", icon: "phone.fill")
                    Divider().padding(.leading, 50)
                    infoRow("Email", "pich@example.com", icon: "envelope.fill")
                    Divider().padding(.leading, 50)
                    infoRow("Gender", "Male", icon: "figure.stand")
                    Divider().padding(.leading, 50)
                    infoRow("Date of Birth", "10 Oct 1995", icon: "calendar")
                    Divider().padding(.leading, 50)
                    infoRow("City / Province", "Phnom Penh", icon: "mappin.circle.fill")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
                )
            }
            .padding()
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.94))
        .navigationTitle("Profile")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color(red: 0.4, green: 0.26, blue: 0.13))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // coming soon
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                        Text("Edit")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color(red: 0.55, green: 0.35, blue: 0.18))
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
                            colors: [Color(red: 0.4, green: 0.26, blue: 0.13), Color(red: 0.55, green: 0.35, blue: 0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: Color(red: 0.4, green: 0.26, blue: 0.13).opacity(0.4), radius: 12, y: 6)
                
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
                    .foregroundStyle(Color(red: 0.2, green: 0.13, blue: 0.07))
                
                Text("Coffee Enthusiast")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.3))
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    func infoRow(_ title: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.92))
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.4, green: 0.26, blue: 0.13))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.3))
                
                Text(value)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.2, green: 0.13, blue: 0.07))
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
    }
}
