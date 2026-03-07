//
//  AppearanceSettingsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/20/26.
//
import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSection(title: "Theme", icon: "paintpalette.fill") {
                    ForEach(Array(AppTheme.allCases.enumerated()), id: \.element.id) { index, theme in
                        RowInSectionView(
                            title: theme.title,
                            systemImage: theme.icon,
                            trailingSystemImage: themeManager.theme == theme ? "checkmark" : ""
                        ) {
                            themeManager.setTheme(theme)
                        }
                        .accentColor(.accentPrimary)
                        
                        if index < AppTheme.allCases.count - 1 {
                            DeviderInSectionView()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .background(Color.bgPrimary)
        .customNavigationBar("Appearance") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }
}
