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
                    .font(.system(size: 20, weight: .bold))
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
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.coffeeDarkBrown)
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
                .font(.system(size: 15))
                .foregroundColor(color)
            
            Spacer()
            
            Text("$\(value, specifier: "%.2f")")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
        }
    }
}
