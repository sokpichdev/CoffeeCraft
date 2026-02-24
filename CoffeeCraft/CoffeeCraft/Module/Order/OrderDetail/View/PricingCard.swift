//
//  PricingCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct PricingCard: View {
    let totalPrice: Double
    let items: [CartItemData]
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    var tax: Double {
        totalPrice - subtotal
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Summary")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                PriceRow(label: "Subtotal", value: subtotal)
                PriceRow(label: "Tax & Fees", value: tax, color: .secondary)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                    .padding(.vertical, 4)
                
                HStack {
                    Text("Total")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct PriceRow: View {
    let label: String
    let value: Double
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(color)
            
            Spacer()
            
            Text("$\(value, specifier: "%.2f")")
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}
