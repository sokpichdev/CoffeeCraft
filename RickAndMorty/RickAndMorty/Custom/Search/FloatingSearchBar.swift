//
//  FloatingSearchBar.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/30/25.
//
import SwiftUI

struct FloatingSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search by name", text: $searchText)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
