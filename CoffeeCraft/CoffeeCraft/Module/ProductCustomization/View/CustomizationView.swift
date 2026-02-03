//
//  CustomizationView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//

import SwiftUI

struct CustomizationView: View {
    @Binding var customizations: [CustomizationCategory]
    @StateObject var customizationVM = CustomizationViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddFromLibrary = false
    @State private var showCreateCustom = false
    @State private var newCategoryName = ""
    
    var body: some View {
        CustomNavigationStack {
            ZStack {
                // Background gradient
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header info card
                        if customizations.isEmpty {
                            EmptyCustomizationsCard()
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        
                        // Existing customizations
                        ForEach($customizations) { $category in
                            CustomizationCategoryCard(
                                category: $category,
                                onDelete: {
                                    withAnimation {
                                        if let index = customizations.firstIndex(where: { $0.id == category.id }) {
                                            customizations.remove(at: index)
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Add buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showAddFromLibrary = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "book.fill")
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Add from Library")
                                            .font(.headline)
                                        Text("Choose pre-defined options")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(Color.brown)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.brown, Color.brown.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .brown.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: {
                                showCreateCustom = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Create Custom")
                                            .font(.headline)
                                        Text("Design your own category")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(Color.brown)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .onAppear {
                customizationVM.fetchCustomizations()
            }
            .customNavigationBar("Customizations") {
                ToolBarButton(placement: .topBarLeading, buttonType: .icon("xmark")) {
                    dismiss()
                }
                
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("checkmark")) {
                    dismiss()
                }
            }
            .sheet(isPresented: $showAddFromLibrary) {
                CustomizationLibrarySheet(
                    availableCustomizations: customizationVM.availableCustomizations,
                    selectedCustomizations: $customizations
                )
            }
            .alert("Create Custom Category", isPresented: $showCreateCustom) {
                TextField("Category name", text: $newCategoryName)
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Create") {
                    if !newCategoryName.isEmpty {
                        withAnimation {
                            customizations.append(CustomizationCategory(name: newCategoryName, options: []))
                        }
                        newCategoryName = ""
                    }
                }
            } message: {
                Text("Enter a name for the customization category (e.g., Size, Milk, Extras)")
            }
        }
    }
}
