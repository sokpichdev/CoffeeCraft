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
    @State private var isURLValid: Bool = false

    var categoryNames: [String] { // get-only property
        productVM.sections.map { $0.name }
    }
    @State private var mutableCategoryNames: [String] = [] // mutable copy
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // MARK: - Image Preview
                VStack(spacing: 16) {
                    AsyncImageCard(imageURL: tempImageURL, height: 200, width: UIScreen.main.bounds.width - 32)

                    VStack(alignment: .leading, spacing: 0) {
                        CustomProductTextField(title: "Image URL", text: $tempImageURL, icon: "photo")
                        if !isURLValid {
                            CustomAttributedStringText(TextSegment(text: "No Image URL?", color: .red, font: .caption),
                                                       TextSegment(text: "Click Here to get!",
                                                                   color: .brown,
                                                                   font: .caption,
                                                                   link: URL(string: "https://postimages.org/")!,
                                                                  underline: true))
                            .padding(.leading)
                        }
                    }
                    .padding()
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
            
            if mutableCategoryNames.isEmpty {
                mutableCategoryNames = categoryNames
            }
        }
        .onChange(of: tempImageURL) {
            isURLValid = (URL(string: tempImageURL) != nil) && !tempImageURL.isEmpty
        }
        .onChange(of: tempCategory) {
            if !mutableCategoryNames.contains(tempCategory) {
                mutableCategoryNames.append(tempCategory)
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            CategorySelectionSheet(
                categories: mutableCategoryNames,
                selectedCategory: $tempCategory
            )
            .presentationDetents([.medium, .large])
        }
    }
}
