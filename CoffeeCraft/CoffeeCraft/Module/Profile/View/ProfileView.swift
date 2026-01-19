//
//  ProfileView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var name = ""
    @State private var phone = ""
    @State private var gender = ""
    @State private var dob = Date()
    @State private var city = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileHeader
                
                VStack(spacing: 0) {
                    RowInSectionView(label: "Name", title: authVM.currentUser?.name ?? "-", systemImage: "person.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Phone", title: authVM.currentUser?.phoneNumber ?? "-", systemImage: "phone.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Email", title: authVM.currentUser?.email ?? "-", systemImage: "envelope.fill")
                    DeviderInSectionView()
                    RowInSectionView(label: "Gender", title: authVM.currentUser?.gender ?? "-", systemImage: "figure.stand")
                    DeviderInSectionView()
                    RowInSectionView(label: "Date of Birth", title: authVM.currentUser?.dateOfBirth?.formatted(date: .long, time: .omitted) ?? "-", systemImage: "calendar")
                    DeviderInSectionView()
                    RowInSectionView(label: "City / Province", title: authVM.currentUser?.city ?? "-", systemImage: "mappin.circle.fill")

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
                    isEditing = true
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
        .onAppear {
            if let user = authVM.currentUser {
                name = user.name
                phone = user.phoneNumber ?? ""
                gender = user.gender ?? ""
                dob = user.dateOfBirth ?? Date()
                city = user.city ?? ""
            }
        }
        .sheet(isPresented: $isEditing) {
            if let user = authVM.currentUser {
                EditProfileView(
                    name: user.name,
                    phone: user.phoneNumber ?? "",
                    gender: user.gender ?? "",
                    dob: user.dateOfBirth ?? Date(),
                    city: user.city ?? ""
                )
                .environmentObject(authVM)
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
