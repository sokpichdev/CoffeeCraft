//
//  FavoriteView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var favoriteVM: FavoriteViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(favoriteVM.favorites) { item in
                    FavoriteRowItemView(item: item)
                }
            }
            .padding()
        }
        .navigationBarTitle("Favorites", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
        .task {
            await favoriteVM.loadAllFavorites()
        }
    }
}
