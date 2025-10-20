//
//  CustomerHomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CustomerHomeView: View {
    @StateObject private var productVM = ProductViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if productVM.isLoading {
                    ProgressView("Loading coffee menu...")
                } else if let error = productVM.errorMessage {
                    VStack {
                        Text("⚠️ \(error)")
                        Button("Retry") {
                            Task { await productVM.fetchProducts() }
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(productVM.products) { product in
                                ProductCardView(product: product)
                            }
                            
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Coffee Menu")
        }
        .task {
            await productVM.fetchProducts()
        }
    }
}

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(product.name)
                .font(.headline)

            Text("$\(product.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
    }
}
