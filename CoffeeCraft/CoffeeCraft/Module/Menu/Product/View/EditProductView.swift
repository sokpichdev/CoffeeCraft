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
    var productCustomizations: [String: [String: Double]]
    
    @State private var tempName: String = ""
    @State private var tempDescription: String = ""
    @State private var tempPrice: Double = 0.0
    @State private var tempCategory: String = ""
    @State private var tempImageURL: String = ""
    @State private var tempCustomizations: [CustomizationCategory] = []
    @State private var tempAvailable: Bool = true
    
    var isEditing: Bool = true
    @State private var showCategorySheet: Bool = false
    @State private var showWebView: Bool = false
    @State private var webViewURL: URL?

    @State private var isURLValid: Bool = false

    var categoryNames: [String] {
        productVM.sections.map { $0.name }
    }
    @State private var mutableCategoryNames: [String] = []
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 32) {
                // MARK: - Image Preview
                VStack(spacing: 16) {
                    AsyncImageCard(imageURL: tempImageURL, height: 200, width: UIScreen.main.bounds.width - 32)

                    VStack(alignment: .leading, spacing: 0) {
                        CustomProductTextField(title: "Image URL", text: $tempImageURL, icon: "photo")
                        if !isURLValid {
//                            CustomAttributedStringText(TextSegment(text: "No Image URL?", color: .red, font: .caption),
//                                                       TextSegment(text: "Click Here to get!",
//                                                                   color: .accentPrimary,
//                                                                   font: .caption,
//                                                                   link: URL(string: "https://postimages.org/")!,
//                                                                  underline: true))
//                            .padding(.leading)
                            Button(action: {
                                if let url = URL(string: "https://postimages.org/") {
                                    webViewURL = url
                                    showWebView = true
                                }
                            }, label: {
                                HStack {
                                    (
                                        Text("No Image URL?").foregroundColor(.red).font(.caption) +
                                        Text(" Click Here to get!").foregroundColor(.accentPrimary).font(.caption)
                                    )
                                }
                                .padding(.leading)
                                .padding(.top, 5)
                            })
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
                }
                .padding(.horizontal)

                // MARK: - Product Info
                VStack(alignment: .leading, spacing: 16) {
                    Label("Basic Info", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundColor(.accentPrimary)
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
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
                .padding(.horizontal)

                // MARK: - Customizations
                VStack(alignment: .leading, spacing: 16) {
                    Label("Product Options", systemImage: "slider.horizontal.3")
                        .font(.headline)
                        .foregroundColor(.accentPrimary)
                        .padding(.bottom, 4)
                    
                    CustomizationEditorButton(customizations: $tempCustomizations)
                    
                    // Display added customizations
                    if !tempCustomizations.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(tempCustomizations) { category in
                                CustomizationPreviewCard(category: category)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
                .padding(.horizontal)

                // MARK: - Availability Toggle
                VStack(alignment: .leading, spacing: 12) {
                    Label("Status", systemImage: "checkmark.circle")
                        .font(.headline)
                        .foregroundColor(.accentPrimary)
                        .padding(.bottom, 4)
                    
                    Toggle("Available for order", isOn: $tempAvailable)
                        .toggleStyle(SwitchToggleStyle(tint: .accentPrimary))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
                .padding(.horizontal)

                // MARK: - Save Button
                Button(action: {
                    Task {
                        // Convert CustomizationCategory array back to Firebase format
                        var customizationsDict: [String: [String: Double]] = [:]
                        for category in tempCustomizations {
                            customizationsDict[category.name] = category.toFirebaseFormat()
                        }
                        
                        await productVM.saveProduct(Product(
                            id: productID,
                            name: tempName,
                            description: tempDescription,
                            price: tempPrice,
                            imageURL: tempImageURL,
                            category: tempCategory,
                            available: tempAvailable,
                            customizations: customizationsDict
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
                    .background(Color.accentPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 20)
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
        }, onRefresh: {
        })
        .background(Color.bgSecondary)
        .customNavigationBar(isEditing ? "Edit Product" : "Add Product") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            tempName = productName
            tempDescription = productDescription
            tempPrice = productPrice
            tempCategory = productCategory
            tempImageURL = productImageURL
            tempAvailable = productAvailable
            
            // Convert Firebase format to CustomizationCategory array
            tempCustomizations = productCustomizations.map { key, value in
                CustomizationCategory.fromFirebaseFormat(name: key, data: value)
            }.sorted { $0.name < $1.name }
            
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
        .sheet(isPresented: $showWebView) {
            CustomNavigationStack {
                if let url = webViewURL {
                    WebView(url: url)
                        .customNavigationBar("Get Image") {
                            ToolBarButton(placement: .cancellationAction, buttonType: .text("Done")) {
                                showWebView = false
                            }
                        }
                }
            }
        }
    }
}
