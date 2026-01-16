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
            return ("matches description", .green)
        case .price:
            return ("", .clear)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: URL(string: product.imageURL))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(width: 70, height: 70)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.primary)
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
                    .padding(.vertical, 3)
                    .background(matchBadge.1.opacity(0.15))
                    .cornerRadius(6)
                }
                
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
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
