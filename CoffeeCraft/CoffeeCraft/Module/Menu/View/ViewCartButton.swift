//
//  ViewCartButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/21/25.
//
import SwiftUI

struct ViewCartButton: View {
    @ObservedObject var cartManager: CartManager
    var onTap: () -> Void

    var totalDrinks: Int { cartManager.items.count }
    var formattedTotal: String { String(format: "$%.2f", cartManager.total) }

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Button(action: onTap) {
                HStack {
                    Image(systemName: "cart.fill")
                        .font(.title3)
                    
                    Text("View Cart (\(totalDrinks) drink\(totalDrinks > 1 ? "s" : ""))")
                        .font(.headline)
                    Spacer()
                    
                    Text(formattedTotal)
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.textPrimary).colorScheme(.light)
                .background(Color.semanticSuccess)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(radius: 4)
                .padding([.horizontal, .bottom])
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.height < -20 { onTap() } // drag up to open
                    }
            )
        }
    }
}
