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
    
    @State private var selectedTab = 0 //0 = view, 1 = edit
    
    @State private var name = ""
    @State private var phone = ""
    @State private var gender = ""
    @State private var dob = Date()
    @State private var city = ""
    
    @State private var showGenderPicker = false
    @State private var showCityPicker = false
    @State private var isSaving = false
    
    let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    let cityOptions: [String] = ["Phnom Penh", "Siem Reap", "Battambang", "Preah Sihanouk", "Kampong Cham",
        "Kandal", "Takeo", "Prey Veng", "Kampot", "Pursat", "Banteay Meanchey",
        "Kampong Thom", "Kampong Speu", "Koh Kong", "Kratie", "Mondulkiri",
        "Oddar Meanchey", "Pailin", "Preah Vihear", "Ratanakiri", "Stung Treng",
        "Svay Rieng", "Tbong Khmum"
    ]
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 0) {
                viewTab.frame(width: geo.size.width)
                editTab.frame(width: geo.size.width)
            }
            .offset(x: selectedTab == 0 ? 0 : -geo.size.width)
            .animation(.spring(response: 0.42, dampingFraction: 0.88), value: selectedTab)
        }
        .clipped()
        .background(Color(.systemGroupedBackground))
        
        .customNavigationBar(selectedTab == 0 ? "Profile" : "Edit Profile") {
            if selectedTab == 0 {
                ToolBarButton.back { dismiss() }
                ToolBarButton(placement: .topBarTrailing, buttonType: .text("Edit")) {
                    startEditing()
                }
            } else {
                ToolBarButton(placement: .topBarLeading, buttonType: .text("Cancel")) {
                    cancelEditing()
                }
                if isSaving {
                    ToolBarProgress(placement: .topBarTrailing)
                } else {
                    ToolBarButton(placement: .topBarTrailing, buttonType: .text("Save")) {
                        saveProfile()
                    }
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .sheet(isPresented: $showGenderPicker) {
            PickerSheetView(
                title: "Select Gender",
                options: genderOptions,
                selectedOption: $gender
            )
            .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $showCityPicker) {
            PickerSheetView(
                title: "Select City / Province",
                options: cityOptions,
                selectedOption: $city
            )
            .presentationDetents([.medium])
        }
        .onAppear { loadUserData() }
    }
    
    private var viewTab: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileHeader
                infoCard(isEditing: false)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var editTab: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileHeader
                infoCard(isEditing: true)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    @ViewBuilder
    private func infoCard(isEditing: Bool) -> some View {
        let isEditingBinding = Binding.constant(isEditing)
        
        VStack(spacing: 0) {
            RowInProfileView(title: $name,
                             isEditing: isEditingBinding,
                             label: "Name",
                             systemImage: "person.fill",
                             editType: .name) {}
            DeviderInSectionView()
            
            RowInProfileView(title: $phone,
                             isEditing: isEditingBinding,
                             label: "Phone",
                             systemImage: "phone.fill",
                             editType: .phone) {}
            DeviderInSectionView()
            
            RowInProfileView(title: .constant(authVM.currentUser?.email ?? "-"),
                             isEditing: isEditingBinding,
                             label: "Email",
                             systemImage: "envelope.fill",
                             editType: .email) {}
            DeviderInSectionView()
            
            RowInProfileView(title: $gender,
                             isEditing: isEditingBinding,
                             previousTitle: authVM.currentUser?.gender ?? "-",
                             label: "Gender",
                             systemImage: "figure.stand",
                             editType: .dropDown) {
                Button {
                    showGenderPicker = true
                } label: {
                    Text(gender.isEmpty ? "Select" : gender)
                        .font(.headline)
                        .foregroundStyle(gender.isEmpty ? .secondary : .primary)
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.brown)
                }
                .buttonStyle(PlainButtonStyle())
            }
            DeviderInSectionView()
            
            RowInProfileView(
                title: .constant(dob.formatted(date: .long, time: .omitted)),
                isEditing: isEditingBinding,
                previousTitle: authVM.currentUser?.dateOfBirth?.formatted(date: .long, time: .omitted) ?? "-",
                label: "Date of Birth",
                systemImage: "calendar",
                editType: .date
            ) {
                DatePicker("", selection: $dob, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
            }
            DeviderInSectionView()
            
            RowInProfileView(title: $city,
                             isEditing: isEditingBinding,
                             previousTitle: authVM.currentUser?.city ?? "-",
                             label: "City / Province",
                             systemImage: "mappin.circle.fill",
                             editType: .dropDown) {
                Button {
                    showCityPicker = true
                } label: {
                    Text(city.isEmpty ? "Select" : city)
                        .font(.headline)
                        .foregroundStyle(city.isEmpty ? .secondary : .primary)
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.brown)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
        )
    }
    
    private var profileHeader: some View {
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
                Text(authVM.currentUser?.name ?? "User")
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
    
    private func loadUserData() {
        guard let user = authVM.currentUser else { return }
        name = user.name
        phone = user.phoneNumber ?? ""
        gender = user.gender ?? ""
        dob = user.dateOfBirth ?? Date()
        city = user.city ?? ""
    }
    
    private func startEditing() {
        loadUserData()
        withAnimation { selectedTab = 1 }
    }
    
    private func cancelEditing() {
        loadUserData()
        withAnimation { selectedTab = 0 }
    }
    
    private func saveProfile() {
        guard var user = authVM.currentUser else { return }
        isSaving = true
        
        user.name = name
        user.phoneNumber = phone
        user.gender = gender
        user.dateOfBirth = dob
        user.city = city
        
        Task {
            let success = await authVM.updateProfile(user: user)
            await MainActor.run {
                isSaving = false
                ToastManager.shared.show(message: "Profile updated successfully", type: .success)
                if success {
                    withAnimation { selectedTab = 0 }
                }
            }
        }
    }
}
