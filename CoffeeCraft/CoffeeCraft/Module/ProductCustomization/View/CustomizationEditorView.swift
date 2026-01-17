//
//  CustomizationEditorView.swift
//  CoffeeCraft
//
//  View for editing product customizations
//

import SwiftUI

struct CustomizationEditorView: View {
    @Binding var customizations: [CustomizationCategory]
    @StateObject private var customizationVM = CustomizationViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddFromLibrary = false
    @State private var showCreateCustom = false
    @State private var newCategoryName = ""
    
    var body: some View {
        NavigationView {
            List {
                // Existing customizations for this product
                ForEach($customizations) { $category in
                    Section {
                        ForEach($category.options) { $option in
                            HStack {
                                TextField("Option name", text: $option.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Spacer()
                                
                                Text("$")
                                    .foregroundColor(.secondary)
                                
                                TextField("0.00", value: $option.price, format: .number.precision(.fractionLength(2)))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .onDelete { indices in
                            category.options.remove(atOffsets: indices)
                        }
                        
                        Button(action: {
                            category.options.append(CustomizationOption(name: "", price: 0.0))
                        }) {
                            Label("Add Option", systemImage: "plus.circle.fill")
                                .foregroundColor(.brown)
                        }
                    } header: {
                        HStack {
                            TextField("Category name", text: $category.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                if let index = customizations.firstIndex(where: { $0.id == category.id }) {
                                    customizations.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Add buttons section
                Section {
                    Button(action: {
                        showAddFromLibrary = true
                    }) {
                        Label("Add from Library", systemImage: "book.fill")
                            .foregroundColor(.brown)
                            .fontWeight(.semibold)
                    }
                    
                    Button(action: {
                        showCreateCustom = true
                    }) {
                        Label("Create Custom Category", systemImage: "plus.circle.fill")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Customizations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
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
                        customizations.append(CustomizationCategory(name: newCategoryName, options: []))
                        newCategoryName = ""
                    }
                }
            } message: {
                Text("Enter a name for the customization category (e.g., Size, Milk, Extras)")
            }
        }
    }
}

// Sheet to select from pre-defined customizations
struct CustomizationLibrarySheet: View {
    let availableCustomizations: [CustomizationCategory]
    @Binding var selectedCustomizations: [CustomizationCategory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if availableCustomizations.isEmpty {
                    ContentUnavailableView(
                        "No Customizations Available",
                        systemImage: "tray",
                        description: Text("Run the customization seeder to populate options")
                    )
                } else {
                    ForEach(availableCustomizations) { category in
                        Button(action: {
                            addCustomization(category)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(category.options.count) options")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Show checkmark if already added
                                if selectedCustomizations.contains(where: { $0.name == category.name }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.brown)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.brown)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Customization Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addCustomization(_ category: CustomizationCategory) {
        // Check if already exists
        if let existingIndex = selectedCustomizations.firstIndex(where: { $0.name == category.name }) {
            // Remove it (toggle)
            selectedCustomizations.remove(at: existingIndex)
        } else {
            // Add it with a new ID
            var newCategory = category
            newCategory.id = UUID() // Create new ID for this product's instance
            selectedCustomizations.append(newCategory)
        }
    }
}

// Compact button to show in the product editor
struct CustomizationEditorButton: View {
    @Binding var customizations: [CustomizationCategory]
    @State private var showEditor = false
    
    var body: some View {
        Button(action: {
            showEditor = true
        }) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.brown)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Customizations")
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                    
                    if customizations.isEmpty {
                        Text("No customizations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(customizations.count) categories")
                            .font(.caption)
                            .foregroundColor(.brown)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showEditor) {
            CustomizationEditorView(customizations: $customizations)
        }
    }
}
