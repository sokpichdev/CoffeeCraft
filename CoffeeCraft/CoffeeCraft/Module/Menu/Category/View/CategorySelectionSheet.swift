//
//  CategorySelectionSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct CategorySelectionSheet: View {
    @State var categories: [String]
    @Binding var selectedCategory: String
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var tempSelectedCategory: String = ""
    @State private var tempCategories: [String] = []
    
    var filteredCategories: [String] {
        let all = categories + tempCategories
        if searchText.isEmpty {
            return all
        } else {
            return all.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search Categories", text: $searchText)
                    .padding(8)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .padding([.top, .horizontal])
                ScrollView(showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredCategories, id: \.self) { category in
                            Button(action: {
                                tempSelectedCategory = category
                            }) {
                                HStack {
                                    Text(category)
                                        .foregroundColor(category == tempSelectedCategory ? .brown : .primary) // Highlight selected text
                                        .fontWeight(category == tempSelectedCategory ? .semibold : .regular)
                                    
                                    Spacer()
                                    
                                    if category == tempSelectedCategory {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.brown)
                                    }
                                }
                                .padding()
                                .padding(.horizontal)
                                .background(category == tempSelectedCategory ? Color.brown.opacity(0.1) : Color.clear)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if filteredCategories.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .foregroundColor(.brown.opacity(0.6))
                                
                                Text("No category found for “\(searchText)”")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                
                                Button("Add as New Category") {
                                    withAnimation {
                                        tempCategories.append(searchText)
                                        tempSelectedCategory = searchText
                                        searchText = ""
                                    }
                                }
                                .font(.subheadline.bold())
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.brown)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 40)
                            .transition(.opacity)
                        }
                    }
                    .padding(.top)
                }
            }
            .customNavigationBar("Select Category")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedCategory = tempSelectedCategory
                        dismiss()
                    }
                    .foregroundColor(.brown)
                }
            }
            .onAppear {
                tempSelectedCategory = selectedCategory
            }
        }
    }
}
