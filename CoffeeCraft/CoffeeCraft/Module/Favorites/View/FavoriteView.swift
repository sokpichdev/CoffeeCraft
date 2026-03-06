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
        CustomRefreshScrollView( {

            LazyVStack(spacing: 12) {
                ForEach(favoriteVM.favorites) { item in
                    FavoriteRowItemView(item: item)
                }
            }
            .padding()
        }, onRefresh: {
        })
        .background(Color.bgPrimary)
        .customNavigationBar("Favorites") {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("plus")) {
            }
        }
        .task {
            await favoriteVM.loadAllFavorites()
        }
    }
}
