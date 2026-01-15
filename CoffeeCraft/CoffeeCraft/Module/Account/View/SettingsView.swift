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
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
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
                    .font(.headline)
                    .foregroundColor(Color.brown)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
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
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brown)
                }
                
                Text(title)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
            .padding(.vertical, 14)
        }
        .foregroundStyle(.primary)
    }
}
