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
    
    @State private var isNavigateToAppearance: Bool = false
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                        isNavigateToAppearance = true
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
                
                Button {
                    authVM.logout() { isSuccess in
                        if isSuccess {
                            dismiss()
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.system(size: 18))
                        
                        Text("Logout")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.red.opacity(0.4), radius: 8, y: 4)
                    )
                }
                .padding(.top, 8)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Setting") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $isNavigateToAppearance) {
            AppearanceSettingsView().environmentObject(themeManager)
        }
    }
}
