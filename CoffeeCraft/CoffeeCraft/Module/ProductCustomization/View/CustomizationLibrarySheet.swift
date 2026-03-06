//
//  CustomizationLibrarySheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct CustomizationLibrarySheet: View {
    let availableCustomizations: [CustomizationCategory]
    @Binding var selectedCustomizations: [CustomizationCategory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        CustomNavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if availableCustomizations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.brown.opacity(0.4))
                        
                        Text("No Customizations Available")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Run the customization seeder to populate pre-defined options")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    CustomRefreshScrollView( {
                        LazyVStack(spacing: 12) {
                            ForEach(availableCustomizations) { category in
                                LibraryCategoryCard(
                                    category: category,
                                    isSelected: selectedCustomizations.contains(where: { $0.name == category.name }),
                                    onToggle: {
                                        addCustomization(category)
                                    }
                                )
                            }
                        }
                        .padding()
                    }, onRefresh: {
                    })
                }
            }
            .customNavigationBar("Customization Library") {
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("checkmark")) {
                    dismiss()
                }
            }
        }
    }
    
    private func addCustomization(_ category: CustomizationCategory) {
        withAnimation {
            if let existingIndex = selectedCustomizations.firstIndex(where: { $0.name == category.name }) {
                selectedCustomizations.remove(at: existingIndex)
            } else {
                var newCategory = category
                newCategory.id = UUID()
                selectedCustomizations.append(newCategory)
            }
        }
    }
}
