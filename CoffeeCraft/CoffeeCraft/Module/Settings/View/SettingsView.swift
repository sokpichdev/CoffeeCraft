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
                    RowInSectionView(title: "Account Settings", systemImage: "gearshape.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Face ID & PIN", systemImage: "faceid")
                }
                
                settingsSection(title: "Connections", icon: "link.circle.fill") {
                    RowInSectionView(title: "Connected Accounts", systemImage: "network")
                }
                
                settingsSection(title: "Preferences", icon: "paintbrush.fill") {
                    RowInSectionView(title: "Appearance", systemImage: "sparkles")
                    DeviderInSectionView()
                    RowInSectionView(title: "Languages", systemImage: "globe")
                }
                
                settingsSection(title: "Support", icon: "questionmark.circle.fill") {
                    RowInSectionView(title: "FAQs", systemImage: "doc.text.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Terms & Conditions", systemImage: "doc.plaintext")
                    DeviderInSectionView()
                    RowInSectionView(title: "About Us", systemImage: "info.circle.fill")
                }
                
                settingsSection(title: "Share the Love", icon: "heart.circle.fill") {
                    RowInSectionView(title: "Share the App", systemImage: "square.and.arrow.up.fill")
                    DeviderInSectionView()
                    RowInSectionView(title: "Write a Review", systemImage: "star.fill")
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
        .navigationBarTitle("Settings", displayMode: .inline)
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
}
