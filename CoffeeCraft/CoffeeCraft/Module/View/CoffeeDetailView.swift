//
//  CoffeeDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct CoffeeDetailView: View {
    @EnvironmentObject var cartManager: CartManager
    let product: Product

    @State private var selectedSize: String = ""
    @State private var selectedMilk: String = ""
    @State private var selectedSugar: String = "Normal"
    @State private var selectedIce: String = "Regular"
    @State private var selectedExtras: [String] = []
    @State private var showAddedAlert = false

    var sugarLevels = ["No Sugar", "Less", "Normal", "Extra"]
    var iceLevels = ["No Ice", "Less", "Regular", "Extra"]

    // MARK: - Subtotal calculation matching CartItem.totalPrice
    private var subtotal: Double {
        var price = product.price

        // Size adjustments
        switch selectedSize {
        case "Small": price += 0
        case "Medium": price += 0.5
        case "Large": price += 1.0
        default: break
        }

        // Milk adjustments
        switch selectedMilk {
        case "Whole": price += 0
        case "Oat": price += 0.5
        case "Soy": price += 0.5
        case "Almond": price += 0.5
        default: break
        }

        // Extras adjustments
        price += Double(selectedExtras.count) * 0.5

        return price
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WebImage(url: URL(string: product.imageURL))
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(20)
                        .shadow(radius: 5)

                    // Name & Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Customizations
                    VStack(alignment: .leading, spacing: 16) {
                        if let sizes = product.customizations?["Size"] {
                            CustomSelectionChips(title: "Size", options: sizes, selected: $selectedSize)
                        }
                        if let milks = product.customizations?["Milk"] {
                            CustomSelectionChips(title: "Milk", options: milks, selected: $selectedMilk)
                        }
                        CustomSelectionChips(title: "Sugar", options: sugarLevels, selected: $selectedSugar)
                        CustomSelectionChips(title: "Ice", options: iceLevels, selected: $selectedIce)
                        if let extras = product.customizations?["Extras"] {
                            MultiSelectionChips(title: "Extras", options: extras, selected: $selectedExtras)
                        }
                    }

                    Spacer(minLength: 120) // Space for sticky footer
                }
                .padding()
            }
            // MARK: Sticky Footer: Subtotal + Add to Cart
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", subtotal))
                        .font(.title2)
                        .bold()
                }

                Button(action: {
                    cartManager.addToCart(
                        product: product,
                        size: selectedSize,
                        milk: selectedMilk,
                        sugar: selectedSugar,
                        ice: selectedIce,
                        extras: selectedExtras
                    )
                    showAddedAlert = true
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .alert("Added to Cart ☕️", isPresented: $showAddedAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            .padding()
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(radius: 5)
        }
        .onAppear {
            // Default selections
            if let sizes = product.customizations?["Size"], selectedSize.isEmpty {
                selectedSize = sizes.first ?? ""
            }
            if let milks = product.customizations?["Milk"], selectedMilk.isEmpty {
                selectedMilk = milks.first ?? ""
            }
        }
        .frame(maxHeight: .infinity) // make VStack fill the screen
        .ignoresSafeArea() // ensures it touches bottom
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Single Selection Chips
struct CustomSelectionChips: View {
    var title: String
    var options: [String]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selected == option ? Color.brown : Color.gray.opacity(0.2))
                            .foregroundColor(selected == option ? .white : .primary)
                            .cornerRadius(12)
                            .onTapGesture { selected = option }
                    }
                }
            }
        }
    }
}

// MARK: - Multi Selection Chips
struct MultiSelectionChips: View {
    var title: String
    var options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selected.contains(option) ? Color.brown : Color.gray.opacity(0.2))
                            .foregroundColor(selected.contains(option) ? .white : .primary)
                            .cornerRadius(12)
                            .onTapGesture {
                                if selected.contains(option) {
                                    selected.removeAll { $0 == option }
                                } else {
                                    selected.append(option)
                                }
                            }
                    }
                }
            }
        }
    }
}
