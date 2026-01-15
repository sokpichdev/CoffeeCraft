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
                    RowInSectionView(label: "Name", title: "Sok Pich", systemImage: "person.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Phone", title: "+855 77 742 462", systemImage: "phone.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Email", title: "pichsok016@example.com", systemImage: "envelope.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Gender", title: "Male", systemImage: "figure.stand")
                    DeviderInSectionView()
                    RowInSectionView(label: "Date of Birth", title: "17 Sep 2001", systemImage: "calendar")
                    DeviderInSectionView()
                    RowInSectionView(label: "City / Province", title: "Phnom Penh", systemImage: "mappin.circle.fill")
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
}
