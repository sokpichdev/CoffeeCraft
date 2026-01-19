//
//  EditProfileView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/19/26.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State var name: String
    @State var phone: String
    @State var gender: String
    @State var dob: Date
    @State var city: String
    
    @State private var showingSaveAlert = false
    @State private var isSaving = false
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, phone, city
    }

    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Avatar Section
                    profileAvatarSection
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        customTextField(
                            label: "Full Name",
                            text: $name,
                            icon: "person.fill",
                            field: .name
                        )
                        
                        customTextField(
                            label: "Phone Number",
                            text: $phone,
                            icon: "phone.fill",
                            field: .phone,
                            keyboardType: .phonePad
                        )
                        
                        customPicker(
                            label: "Gender",
                            selection: $gender,
                            icon: "figure.stand"
                        )
                        
                        customDatePicker(
                            label: "Date of Birth",
                            selection: $dob,
                            icon: "calendar"
                        )
                        
                        customTextField(
                            label: "City / Province",
                            text: $city,
                            icon: "mappin.circle.fill",
                            field: .city
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Save Button
                    saveButton
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.brown)
                    }
                }
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been successfully updated.")
            }
    }
    
    // MARK: - Profile Avatar Section
    private var profileAvatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brown, Color.brown.opacity(0.75), Color.brown.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.brown.opacity(0.3), radius: 10, y: 5)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.white)
                
                // Camera button overlay
                Circle()
                    .fill(Color.brown)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    .offset(x: 35, y: 35)
            }
            
            Text("Tap to change photo")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Custom TextField
    @ViewBuilder
    private func customTextField(
        label: String,
        text: Binding<String>,
        icon: String,
        field: Field,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brown.opacity(0.7))
                    .frame(width: 24)
                
                TextField(label, text: text)
                    .font(.body)
                    .keyboardType(keyboardType)
                    .focused($focusedField, equals: field)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focusedField == field ? Color.brown.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Custom Picker
    @ViewBuilder
    private func customPicker(
        label: String,
        selection: Binding<String>,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Menu {
                Button {
                    selection.wrappedValue = "Male"
                } label: {
                    HStack {
                        Text("Male")
                        if selection.wrappedValue == "Male" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    selection.wrappedValue = "Female"
                } label: {
                    HStack {
                        Text("Female")
                        if selection.wrappedValue == "Female" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    selection.wrappedValue = "Other"
                } label: {
                    HStack {
                        Text("Other")
                        if selection.wrappedValue == "Other" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brown.opacity(0.7))
                        .frame(width: 24)
                    
                    Text(selection.wrappedValue.isEmpty ? "Select Gender" : selection.wrappedValue)
                        .font(.body)
                        .foregroundStyle(selection.wrappedValue.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
        }
    }
    
    // MARK: - Custom Date Picker
    @ViewBuilder
    private func customDatePicker(
        label: String,
        selection: Binding<Date>,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brown.opacity(0.7))
                    .frame(width: 24)
                
                DatePicker("", selection: selection, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveProfile()
        } label: {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Save Changes")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.brown, Color.brown.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(.white)
            .shadow(color: Color.brown.opacity(0.4), radius: 8, y: 4)
        }
        .disabled(isSaving || name.isEmpty)
        .opacity(name.isEmpty ? 0.6 : 1.0)
    }

    // MARK: - Save Profile
    private func saveProfile() {
        guard var user = authVM.currentUser else { return }
        
        // Dismiss keyboard
        focusedField = nil
        
        user.name = name
        user.phoneNumber = phone.isEmpty ? nil : phone
        user.gender = gender.isEmpty ? nil : gender
        user.dateOfBirth = dob
        user.city = city.isEmpty ? nil : city

        isSaving = true
        
        Task {
            do {
                try await authVM.updateProfile(user: user)
                await MainActor.run {
                    isSaving = false
                    showingSaveAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    print("Error updating profile: \(error.localizedDescription)")
                }
            }
        }
    }
}
