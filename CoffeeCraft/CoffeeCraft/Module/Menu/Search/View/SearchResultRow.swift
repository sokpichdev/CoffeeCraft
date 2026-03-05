//
//  SearchResultRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI
import SDWebImageSwiftUI

struct SearchResultRow: View {
    let product: Product
    let matchType: SearchResult.MatchType
    let searchText: String
    
    var matchBadge: (String, Color) {
        switch matchType {
        case .name:
            return ("", .clear)
        case .category:
            return ("in \(product.category)", .blue)
        case .description:
            return ("matches description", .coffeeOliveGreen)
        case .price:
            return ("", .clear)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: URL(string: product.imageURL))
                .resizable()
                .indicator(.activity)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                if matchType != .name && !matchBadge.0.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: matchIcon)
                            .font(.caption)
                        Text(matchBadge.0)
                            .font(.caption)
                    }
                    .foregroundColor(matchBadge.1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 1)
                    .background(matchBadge.1.opacity(0.15))
                    .cornerRadius(6)
                }
                
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Spacer(minLength: 0)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(Color.textSecondary)
        }
        .padding(12)
        .frame(height: 90)
        .background(.surfacePrimary)
        .cornerRadius(12)
        .shadow(color: Color.surfacePrimary.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private var matchIcon: String {
        switch matchType {
        case .name: return ""
        case .category: return "folder.fill"
        case .description: return "text.alignleft"
        case .price: return ""
        }
    }
}
