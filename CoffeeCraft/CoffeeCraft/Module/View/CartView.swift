//
//  CartView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cartManager.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.product.name)
                            .font(.headline)
                        Text("\(item.size), \(item.milk)")
                        if !item.extras.isEmpty {
                            Text("Extras: \(item.extras.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text(String(format: "$%.2f", item.totalPrice))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { cartManager.removeFromCart(item: cartManager.items[$0]) }
                }
            }
            .navigationTitle("My Cart")
            .toolbar {
                Text("Total: $\(cartManager.total, specifier: "%.2f")")
            }
        }
    }
}
