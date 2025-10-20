//
//  CustomerHomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CustomerHomeView: View {
    @StateObject private var productVM = ProductViewModel()
    @StateObject private var cartManager = CartManager()

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
                                NavigationLink(value: product) {
                                    ProductCardView(product: product)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Coffee Menu")
            .navigationDestination(for: Product.self) { product in
                CoffeeDetailView(product: product)
                    .environmentObject(cartManager)
            }
        }
        .task {
            await productVM.fetchProducts()
        }
    }
}
