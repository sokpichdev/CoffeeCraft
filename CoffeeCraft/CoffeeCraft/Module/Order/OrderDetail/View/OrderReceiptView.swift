//
//  OrderReceiptView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

// MARK: - Order Receipt View (Sheet)
struct OrderReceiptView: View {
    let order: Order
    let userName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Receipt Header
                    VStack(spacing: 8) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.coffeeDarkBrown)
                        
                        Text("CoffeeCraft")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Order Receipt")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Receipt Content
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                        
                        HStack {
                            Text("Order #\(order.orderId)")
                            Spacer()
                            Text(order.timestamp.formatted(date: .numeric, time: .shortened))
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        // Items
                        ForEach(order.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .medium))
                                    if let selections = item.selections {
                                        Text(selections.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.system(size: 15))
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.system(size: 17, weight: .bold))
                            Spacer()
                            Text("$\(order.totalPrice, specifier: "%.2f")")
                                .font(.system(size: 17, weight: .bold))
                        }
                        
                        Divider()
                        
                        Text("Ordered by: \(userName)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Receipt")
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
}
