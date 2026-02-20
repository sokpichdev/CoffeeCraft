//
//  SettingsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pushScreen) var push
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 20) {
                SettingsSection(title: "Account", icon: "person.crop.circle.fill") {
                    RowInSectionView(title: "Account Settings", systemImage: "gearshape.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Face ID & PIN", systemImage: "faceid")
                }
                
                SettingsSection(title: "Connections", icon: "link.circle.fill") {
                    RowInSectionView(title: "Connected Accounts", systemImage: "network")
                }
                
                SettingsSection(title: "Preferences", icon: "paintbrush.fill") {
                    RowInSectionView(title: "Appearance", systemImage: "sparkles") {
                        push(AnyView(AppearanceSettingsView().environmentObject(themeManager)))
                    }
                    DeviderInSectionView()
                    RowInSectionView(title: "Languages", systemImage: "globe")
                }
                
                SettingsSection(title: "Support", icon: "questionmark.circle.fill") {
                    RowInSectionView(title: "FAQs", systemImage: "doc.text.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Terms & Conditions", systemImage: "doc.plaintext")
                    DeviderInSectionView()
                    RowInSectionView(title: "About Us", systemImage: "info.circle.fill")
                }
                
                SettingsSection(title: "Share the Love", icon: "heart.circle.fill") {
                    RowInSectionView(title: "Share the App", systemImage: "square.and.arrow.up.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Write a Review", systemImage: "star.fill")
                }
                
                CustomCoffeeButton(title: "Logout", buttonImage: "rectangle.portrait.and.arrow.right.fill", bgColors: [Color.red, Color.red.opacity(0.85)], contentPlacement: .leading) {
                    AlertManager.shared.showDestructive(
                        title: "Log Out?",
                        message: "Are you sure you want to log out?",
                        destructiveTitle: "Log Out"
                    ) {
                        authVM.logout { isSuccess in
                            if isSuccess {
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.top, 8)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            }
            .padding()
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Setting") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }
}
