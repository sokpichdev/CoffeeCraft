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
    
    @State private var showGenderPicker = false
    @State private var showCityPicker = false
    @State private var isSaving = false
    
    let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    let cityOptions = ["Phnom Penh", "Siem Reap", "Battambang", "Sihanoukville", "Kampong Cham", "Kandal", "Takeo", "Prey Veng", "Kampot", "Pursat"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileHeader
                
                VStack(spacing: 0) {
                    RowInProfileView(title: $name,
                                     isEditing: $isEditing,
                                     label: "Name",
                                     systemImage: "person.fill",
                                     editType: .name) {}
                    DeviderInSectionView()
                    RowInProfileView(title: $phone,
                                     isEditing: $isEditing,
                                     label: "Phone",
                                     systemImage: "phone.fill",
                                     editType: .phone) {}
                    DeviderInSectionView()
                    // Email (always read-only)
                    RowInProfileView(title: .constant(authVM.currentUser?.email ?? "-"),
                                     isEditing: $isEditing,
                                     label: "Email",
                                     systemImage: "envelope.fill",
                                     editType: .email) {}
                    DeviderInSectionView()

                    RowInProfileView(title: $gender,
                                     isEditing: $isEditing,
                                     previousTitle: authVM.currentUser?.gender ?? "-",
                                     label: "Gender",
                                     systemImage: "figure.stand",
                                     editType: .dropDown) {
                        Button(action: {
                            showGenderPicker = true
                        }, label: {
                            Text(gender.isEmpty ? "Select" : gender)
                                .font(.headline)
                                .foregroundStyle(gender.isEmpty ? .secondary : .primary)
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundColor(Color.brown)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    DeviderInSectionView()
                    RowInProfileView(title: .constant("\(dob.formatted(date: .long, time: .omitted))"),
                                     isEditing: $isEditing,
                                     previousTitle: "\(authVM.currentUser?.dateOfBirth?.formatted(date: .long, time: .omitted) ?? "-")",
                                     label: "Date of Birth",
                                     systemImage: "calendar", editType: .date) {
                        DatePicker("", selection: $dob, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    DeviderInSectionView()
                    
                    // City
                    RowInProfileView(title: $city,
                                     isEditing: $isEditing,
                                     previousTitle: authVM.currentUser?.city ?? "-",
                                     label: "City / Province",
                                     systemImage: "mappin.circle.fill",
                                     editType: .dropDown) {
                        Button(action: {
                            showCityPicker = true
                        }, label: {
                            Text(city.isEmpty ? "Select" : city)
                                .font(.headline)
                                .foregroundStyle(city.isEmpty ? .secondary : .primary)
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundColor(Color.brown)
                        })
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
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(isEditing ? "Editing Profile" : "Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if isEditing {
                        cancelEditing()
                    } else {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 6) {
                        if isEditing {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(Color.brown)
                        } else {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(Color.brown)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isEditing {
                        saveProfile()
                    } else {
                        startEditing()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                            .tint(.brown)
                    } else {
                        HStack(spacing: 6) {
                            Text(isEditing ? "Save" : "Edit")
                                .font(.headline)
                                .foregroundColor(.brown)
                        }
                    }
                }
                .disabled(isSaving || (isEditing && name.isEmpty))
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
    
    func loadUserData() {
        if let user = authVM.currentUser {
            name = user.name
            phone = user.phoneNumber ?? ""
            gender = user.gender ?? ""
            dob = user.dateOfBirth ?? Date()
            city = user.city ?? ""
        }
    }
    
    func startEditing() {
        loadUserData()
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = true
        }
    }
    
    func cancelEditing() {
        loadUserData()
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = false
        }
    }
    
    func saveProfile() {
        guard var user = authVM.currentUser else { return }

        isSaving = true

        // Update local user model
        user.name = name
        user.phoneNumber = phone
        user.gender = gender
        user.dateOfBirth = dob
        user.city = city

        Task {
            let success = await authVM.updateProfile(user: user)

            await MainActor.run {
                isSaving = false

                if success {
                    print("✅ Successfully Updated profile")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditing = false
                    }
                } else {
                    // TODO: show error alert / toast
                    print("❌ Failed to update profile")
                }
            }
        }
    }
}
