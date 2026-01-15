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
                VStack(spacing: 20) {
                    profileSection
                    personalSection
                    shortcutsSection
                    contactsSection
                    footerSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                    }
                }
            }
        }
    }
}

extension AccountView {
    var profileSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brown, Color.brown.opacity(0.75), Color.brown.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
            }
            .shadow(color: Color(red: 0.4, green: 0.26, blue: 0.13).opacity(0.3), radius: 8, y: 4)

            VStack(spacing: 6) {
                Text("Sok Pich")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                NavigationLink {
                    ProfileView()
                } label: {
                    HStack(spacing: 6) {
                        Text("View Profile")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundStyle(Color.brown)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
    }
}

extension AccountView {
    var personalSection: some View {
        sectionContainer(title: "Personal", icon: "person.text.rectangle") {
            AccountRow(title: "Inbox", systemImage: "tray.fill", badgeCount: 3)
            Divider().padding(.leading, 44)
            AccountRow(title: "Personalization", systemImage: "slider.horizontal.3")
            Divider().padding(.leading, 44)
            AccountRow(title: "Favorites", systemImage: "heart.fill")
            Divider().padding(.leading, 44)
            AccountRow(title: "Addresses", systemImage: "location.fill")
            Divider().padding(.leading, 44)
            AccountRow(title: "Vouchers", systemImage: "ticket.fill", badgeCount: 2)
        }
    }
    
    var shortcutsSection: some View {
        sectionContainer(title: "Shortcuts", icon: "bolt.fill") {
            AccountRow(title: "Stores", systemImage: "building.2.fill")
            Divider().padding(.leading, 44)
            AccountRow(title: "Announcements", systemImage: "megaphone.fill")
            Divider().padding(.leading, 44)
            AccountRow(title: "Rewards", systemImage: "gift.fill")
        }
    }
    
    var contactsSection: some View {
        sectionContainer(title: "Contacts", icon: "bubble.left.and.bubble.right.fill") {
            AccountRow(title: "Customer Service", systemImage: "headset")
            Divider().padding(.leading, 44)
            AccountRow(title: "Feedback", systemImage: "bubble.left.fill")
        }
    }
}

extension AccountView {
    var footerSection: some View {
        VStack(spacing: 16) {
            Text("Stay connected with us")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                socialIcon("paperplane.fill")
                socialIcon("link.circle.fill")
                socialIcon("camera.fill")
                socialIcon("music.note")
                socialIcon("play.rectangle.fill")
            }
        }
        .padding(.vertical, 20)
        .padding(.top, 8)
    }
    
    func socialIcon(_ systemName: String) -> some View {
        Button {
            // coming soon
        } label: {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                
                Image(systemName: systemName)
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
        }
    }
}

extension AccountView {
    func sectionContainer<Content: View>(
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
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            )
        }
    }
}

struct AccountRow: View {
    let title: String
    let systemImage: String
    var badgeCount: Int? = nil
    
    var body: some View {
        Button {
            // coming soon
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
                
                Text(title)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                
                Spacer()
                
                if let count = badgeCount {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                }
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
            .padding(.vertical, 12)
        }
        .foregroundStyle(.primary)
    }
}
