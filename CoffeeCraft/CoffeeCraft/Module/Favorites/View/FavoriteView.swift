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
    @Binding var selectedTab: Tab

    var body: some View {
        CustomRefreshScrollView( {
            if favoriteVM.favorites.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(favoriteVM.favorites) { item in
                        FavoriteRowItemView(item: item)
                    }
                }
                .padding()
            }
        }, onRefresh: {
        })
        .background(Color.bgPrimary)
        .customNavigationBar("Favorites") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .task {
            await favoriteVM.loadAllFavorites()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(Color.textMuted)

            VStack(spacing: 8) {
                Text("No favorites yet")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Items you heart will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
                selectedTab = .menu
            } label: {
                Text("Browse Menu")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}
