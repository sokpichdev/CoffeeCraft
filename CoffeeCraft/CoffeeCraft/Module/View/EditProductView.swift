//
//  EditProductView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/27/25.
//
import SwiftUI

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
    
    var isEditing: Bool = false

    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Image Preview
                    VStack {
                        if let url = URL(string: productImageURL), !productImageURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(14)
                            .shadow(radius: 5)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 180)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No Image")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        CustomProductTextField(title: "Image URL", text: $tempImageURL, icon: "photo.on.rectangle.angled")
                    }

                    // MARK: - Product Info
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Basic Info", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundColor(.brown)
                        CustomProductTextField(title: "Name", text: $tempName, icon: "cup.and.saucer.fill")
                        CustomProductTextField(title: "Description", text: $tempDescription, icon: "text.justify")
                        CustomNumberField(title: "Price ($)", value: $tempPrice, icon: "dollarsign.circle.fill")
                        CustomProductTextField(title: "Category", text: $tempCategory, icon: "folder.fill")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))

                    // MARK: - Availability Toggle
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Status", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.brown)
                        Toggle("Available for order", isOn: $tempAvailable)
                            .toggleStyle(SwitchToggleStyle(tint: .brown))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))

                    // MARK: - Save Button
                    Button(action: {
                        Task {
                            await productVM.saveProduct(Product(id: productID,
                                                                name: productName,
                                                                description: productDescription,
                                                                price: productPrice,
                                                                imageURL: productImageURL,
                                                                category: productCategory))
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text(isEditing ? "Save Changes" : "Add Product")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(isEditing ? "Edit Product" : "Add Product")
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
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
    }
}
