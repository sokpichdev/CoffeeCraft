//
//  AccountView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    profileSection
                    
                    personalSection
                    shortcutsSection
                    contactsSection
                    
                    footerSection
                }
                .padding()
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

extension AccountView {
    
    var profileSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Sok Pich")
                    .font(.headline)
                
                NavigationLink("View Profile >") {
                    ProfileView()
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

extension AccountView {
    
    var personalSection: some View {
        sectionContainer(title: "Personal") {
            AccountRow(title: "Inbox", systemImage: "tray")
            AccountRow(title: "Personalization", systemImage: "slider.horizontal.3")
            AccountRow(title: "Favorites", systemImage: "heart")
            AccountRow(title: "Addresses", systemImage: "location")
            AccountRow(title: "Vouchers", systemImage: "ticket")
        }
    }
    
    var shortcutsSection: some View {
        sectionContainer(title: "Shortcuts") {
            AccountRow(title: "Stores", systemImage: "building.2")
            AccountRow(title: "Announcements", systemImage: "megaphone")
            AccountRow(title: "Rewards", systemImage: "gift")
        }
    }
    
    var contactsSection: some View {
        sectionContainer(title: "Contacts") {
            AccountRow(title: "Customer Service", systemImage: "headset")
            AccountRow(title: "Feedback", systemImage: "bubble.left")
        }
    }
}

extension AccountView {
    
    var footerSection: some View {
        VStack(spacing: 12) {
            Text("Stay connected")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 24) {
                socialIcon("paperplane")     // Telegram
                socialIcon("f.circle")       // Facebook
                socialIcon("camera")         // Instagram
                socialIcon("music.note")     // TikTok
                socialIcon("play.rectangle") // YouTube
            }
        }
        .padding(.top, 12)
    }
    
    func socialIcon(_ systemName: String) -> some View {
        Button {
            // coming soon
        } label: {
            Image(systemName: systemName)
                .font(.title2)
        }
    }
}

extension AccountView {
    
    func sectionContainer<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack {
                content()
            }
            .padding()
            .background(.background)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary)
            )
        }
    }
}


struct AccountRow: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        Button {
            // coming soon
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
        }
        .foregroundStyle(.primary)
    }
}
