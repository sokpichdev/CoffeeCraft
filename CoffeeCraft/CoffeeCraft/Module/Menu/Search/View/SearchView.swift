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
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if filteredResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                                .padding(.top, 60)
                            Text("No results found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Try searching with different keywords")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(filteredResults, id: \.product.id) { result in
                            NavigationLink(value: result.product) {
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
            }
            .searchable(text: $searchText, prompt: "Search products...")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.brown)
                    }
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
                    .environmentObject(cartManager)
                    .environmentObject(favVM)
            }
        }
    }
}
