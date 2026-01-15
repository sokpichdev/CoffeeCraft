//
//  SettingsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                settingsSection(title: "Account", icon: "person.crop.circle.fill") {
                    settingRow("Account Settings", icon: "gearshape.fill")
                    Divider().padding(.leading, 50)
                    settingRow("Face ID & PIN", icon: "faceid")
                }
                
                settingsSection(title: "Connections", icon: "link.circle.fill") {
                    settingRow("Connected Accounts", icon: "network")
                }
                
                settingsSection(title: "Preferences", icon: "paintbrush.fill") {
                    settingRow("Appearance", icon: "sparkles")
                    Divider().padding(.leading, 50)
                    settingRow("Languages", icon: "globe")
                }
                
                settingsSection(title: "Support", icon: "questionmark.circle.fill") {
                    settingRow("FAQs", icon: "doc.text.fill")
                    Divider().padding(.leading, 50)
                    settingRow("Terms & Conditions", icon: "doc.plaintext")
                    Divider().padding(.leading, 50)
                    settingRow("About Us", icon: "info.circle.fill")
                }
                
                settingsSection(title: "Share the Love", icon: "heart.circle.fill") {
                    settingRow("Share the App", icon: "square.and.arrow.up.fill")
                    Divider().padding(.leading, 50)
                    settingRow("Write a Review", icon: "star.fill")
                }
                
                Button {
                    // logout action
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
                                    colors: [Color(red: 0.9, green: 0.3, blue: 0.2), Color(red: 0.8, green: 0.25, blue: 0.15)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(red: 0.8, green: 0.25, blue: 0.15).opacity(0.4), radius: 8, y: 4)
                    )
                }
                .padding(.top, 8)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.3))
                    .padding(.top, 12)
            }
            .padding()
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.94))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color(red: 0.4, green: 0.26, blue: 0.13))
                }
            }
        }
    }
    
    func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.55, green: 0.35, blue: 0.18))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.1))
            }
            .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            )
        }
    }
    
    func settingRow(_ title: String, icon: String) -> some View {
        Button {
            // coming soon
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.96, green: 0.94, blue: 0.92))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.4, green: 0.26, blue: 0.13))
                }
                
                Text(title)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.4))
            }
            .padding(.vertical, 14)
        }
        .foregroundStyle(Color(red: 0.2, green: 0.13, blue: 0.07))
    }
}
