//
//  EditProductView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/27/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct EditProductView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var productVM: ProductViewModel
    var productID: String
    
    var productName: String
    var productDescription: String
    var productPrice: Double
    var productCategory: String
    var productImageURL: String
    var productAvailable: Bool
    
    @State private var tempName: String = ""
    @State private var tempDescription: String = ""
    @State private var tempPrice: Double = 0.0
    @State private var tempCategory: String = ""
    @State private var tempImageURL: String = ""
    @State private var tempAvailable: Bool = true
    
    var isEditing: Bool = true
    @State private var showCategorySheet: Bool = false

    var categoryNames: [String] {
        productVM.sections.map { $0.name }
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // MARK: - Image Preview
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.gray.opacity(0.2))
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let url = URL(string: tempImageURL), !tempImageURL.isEmpty {
                            WebImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: 300)
                                .frame(width: UIScreen.main.bounds.width - 32)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    
                    CustomProductTextField(title: "Image URL", text: $tempImageURL, icon: "photo").padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)

                // MARK: - Product Info
                VStack(alignment: .leading, spacing: 16) {
                    Label("Basic Info", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundColor(.brown)
                        .padding(.bottom, 4)

                    VStack(spacing: 12) {
                        CustomProductTextField(title: "Name", text: $tempName, icon: "cup.and.saucer.fill")
                        CustomProductTextField(title: "Description", text: $tempDescription, icon: "text.justify")
                        CustomNumberField(title: "Price ($)", value: $tempPrice, icon: "dollarsign.circle.fill")
                        CategorySelectionButton(title: "Category", category: tempCategory, icon: "folder.fill") {
                            showCategorySheet = true
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                .padding(.horizontal)

                // MARK: - Availability Toggle
                VStack(alignment: .leading, spacing: 12) {
                    Label("Status", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(.brown)
                        .padding(.bottom, 4)
                    
                    Toggle("Available for order", isOn: $tempAvailable)
                        .toggleStyle(SwitchToggleStyle(tint: .brown))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                .padding(.horizontal)

                // MARK: - Save Button
                Button(action: {
                    Task {
                        await productVM.saveProduct(Product(
                            id: productID,
                            name: tempName,
                            description: tempDescription,
                            price: tempPrice,
                            imageURL: tempImageURL,
                            category: tempCategory,
                            available: tempAvailable
                        ))
                        dismiss()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text(isEditing ? "Save Changes" : "Add Product")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 20)
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(isEditing ? "Edit Product" : "Add Product")
        .scrollDismissesKeyboard(.immediately)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
        .onAppear {
            tempName = productName
            tempDescription = productDescription
            tempPrice = productPrice
            tempCategory = productCategory
            tempImageURL = productImageURL
            tempAvailable = productAvailable
        }
        .sheet(isPresented: $showCategorySheet) {
            CategorySelectionSheet(
                categories: categoryNames,
                selectedCategory: $tempCategory
            )
            .presentationDetents([.medium, .large])
        }
    }
}
