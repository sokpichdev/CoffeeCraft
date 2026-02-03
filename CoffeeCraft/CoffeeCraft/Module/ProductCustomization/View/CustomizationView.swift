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
                        if customizationVM.isLoading {
                            ShimmerView()
                                .frame(height: 155)
                                .padding(.top)
                        } else {
                            if customizations.isEmpty {
                                EmptyCustomizationsCard()
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
                            }
                        }
                        
                        // Add buttons
                        VStack(spacing: 12) {
                            ActionCardButton(
                                iconName: "book.fill",
                                title: "Add from Library",
                                subtitle: "Choose pre-defined options",
                                gradientColors: [Color.brown, Color.brown.opacity(0.8)],
                                shadowColor: Color.brown
                            ) {
                                showAddFromLibrary = true
                            }
                            
                            ActionCardButton(
                                iconName: "plus.circle.fill",
                                title: "Create Custom",
                                subtitle: "Design your own category",
                                gradientColors: [Color.orange, Color.orange.opacity(0.8)],
                                shadowColor: Color.orange
                            ) {
                                showCreateCustom = true
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
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
