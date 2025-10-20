//
//  CoffeeDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CoffeeDetailView: View {
    @EnvironmentObject var cartManager: CartManager
    let product: Product

    @State private var selectedSize: String = ""
    @State private var selectedMilk: String = ""
    @State private var selectedSugar: String = "Normal"
    @State private var selectedIce: String = "Regular"
    @State private var selectedExtras: [String] = []

    var sugarLevels = ["No Sugar", "Less", "Normal", "Extra"]
    var iceLevels = ["No Ice", "Less", "Regular", "Extra"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(15)
                } placeholder: {
                    ProgressView()
                }

                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(String(format: "$%.2f", product.price))
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(product.description)
                    .font(.body)

                Divider()

                // Size
                if let sizes = product.customizations?["Size"] {
                    VStack(alignment: .leading) {
                        Text("Size").font(.headline)
                        Picker("Size", selection: $selectedSize) {
                            ForEach(sizes, id: \.self) { size in
                                Text(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                // Milk
                if let milks = product.customizations?["Milk"] {
                    VStack(alignment: .leading) {
                        Text("Milk").font(.headline)
                        Picker("Milk", selection: $selectedMilk) {
                            ForEach(milks, id: \.self) { milk in
                                Text(milk)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                // Sugar
                VStack(alignment: .leading) {
                    Text("Sugar").font(.headline)
                    Picker("Sugar", selection: $selectedSugar) {
                        ForEach(sugarLevels, id: \.self) { sugar in
                            Text(sugar)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Ice
                VStack(alignment: .leading) {
                    Text("Ice").font(.headline)
                    Picker("Ice", selection: $selectedIce) {
                        ForEach(iceLevels, id: \.self) { ice in
                            Text(ice)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Extras
                if let extras = product.customizations?["Extras"] {
                    VStack(alignment: .leading) {
                        Text("Extras").font(.headline)
                        ForEach(extras, id: \.self) { extra in
                            HStack {
                                Text(extra)
                                Spacer()
                                if selectedExtras.contains(extra) {
                                    Image(systemName: "checkmark").foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedExtras.contains(extra) {
                                    selectedExtras.removeAll { $0 == extra }
                                } else {
                                    selectedExtras.append(extra)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Divider()

                // Add to Cart Button
                Button(action: {
                    cartManager.addToCart(
                        product: product,
                        size: selectedSize,
                        milk: selectedMilk,
                        sugar: selectedSugar,
                        ice: selectedIce,
                        extras: selectedExtras
                    )
                }) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(12)
                }
            }
            .padding()
            .onAppear {
                if let sizes = product.customizations?["Size"], selectedSize.isEmpty {
                    selectedSize = sizes.first ?? ""
                }
                if let milks = product.customizations?["Milk"], selectedMilk.isEmpty {
                    selectedMilk = milks.first ?? ""
                }
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }
}
