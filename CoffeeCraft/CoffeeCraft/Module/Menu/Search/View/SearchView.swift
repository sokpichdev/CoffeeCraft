//
//  SearchView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favVM: FavoriteViewModel
    
    let products: [Product]
    @State private var searchText = ""
    
    var filteredResults: [SearchResult] {
        if searchText.isEmpty {
            return products.map { SearchResult(product: $0, matchType: .name) }
        }
        
        return products.compactMap { product in
            if product.name.localizedCaseInsensitiveContains(searchText) {
                return SearchResult(product: product, matchType: .name)
            } else if product.category.localizedCaseInsensitiveContains(searchText) {
                return SearchResult(product: product, matchType: .category)
            } else if product.description.localizedCaseInsensitiveContains(searchText) {
                return SearchResult(product: product, matchType: .description)
            } else if String(product.price).localizedCaseInsensitiveContains(searchText) {
                return SearchResult(product: product, matchType: .price)
            }
            return nil
        }
    }
    
    var body: some View {
        CustomNavigationStack {
            CustomRefreshScrollView( {
                LazyVStack(spacing: 12) {
                    if filteredResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.textSecondary)
                                .padding(.top, 60)
                            Text("No results found")
                                .font(.headline)
                                .foregroundColor(.textSecondary)
                            Text("Try searching with different keywords")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(filteredResults, id: \.product.id) { result in
                            PushLink(value: result.product) { product in
                                ProductDetailView(product: product)
                            } label: {
                                SearchResultRow(
                                    product: result.product,
                                    matchType: result.matchType,
                                    searchText: searchText
                                )
                            }
                        }
                    }
                }
                .padding()
            }, onRefresh: {
                
            })
            .background(Color.bgPrimary)
            .searchable(text: $searchText, prompt: "Search products...")
            .customNavigationBar("Search") {
                ToolBarButton(placement: .navigationBarLeading, buttonType: .icon("xmark")) {
                    dismiss()
                }
            }
        }
    }
}
