//
//  AccountView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct AccountView: View {
    @StateObject var inboxVM = InboxViewModel()
    @EnvironmentObject var favVM: FavoriteViewModel
    @EnvironmentObject var authVM: AuthViewModel
    // navigate
    @State var isNavigateToInbox: Bool = false
    @State var isNavigateToFavorite: Bool = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileSection
                personalSection
                shortcutsSection
                contactsSection
//                Button("Seed Database") {
//                    Task {
//                        await CustomizationSeeder.seedCustomizations()
//                        print("✅ Database seeded successfully!")
//                    }
//                }
                footerSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Account", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                        .environmentObject(authVM)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
    }
    // MARK: Profile
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
            .shadow(color: Color.brown.opacity(0.3), radius: 8, y: 4)
            
            VStack(spacing: 6) {
                Text(authVM.currentUser?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                NavigationLink {
                    ProfileView()
                        .environmentObject(authVM)
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
        .navigationDestination(isPresented: $isNavigateToInbox, destination: {
            InboxView().environmentObject(inboxVM)
        })
        .navigationDestination(isPresented: $isNavigateToFavorite) {
            FavoriteView()
                .environmentObject(favVM)
        }
    }
    // MARK: Personal
    var personalSection: some View {
        sectionContainer(title: "Personal", icon: "person.text.rectangle") {
            RowInSectionView(title: "Inbox", systemImage: "tray.fill",
                             badgeCount: inboxVM.displayedAnnouncements.filter { !$0.isRead }.count) {
                isNavigateToInbox = true
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Personalization", systemImage: "slider.horizontal.3")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Favorites", systemImage: "heart.fill") {
                isNavigateToFavorite = true
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Addresses", systemImage: "location.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Vouchers", systemImage: "ticket.fill", badgeCount: 2)
        }
    }
    
    // MARK: ShortCuts
    var shortcutsSection: some View {
        sectionContainer(title: "Shortcuts", icon: "bolt.fill") {
            RowInSectionView(title: "Stores", systemImage: "building.2.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Announcements", systemImage: "megaphone.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Rewards", systemImage: "gift.fill")
        }
    }
    
    // MARK: contacts
    var contactsSection: some View {
        sectionContainer(title: "Contacts", icon: "bubble.left.and.bubble.right.fill") {
            RowInSectionView(title: "Customer Service", systemImage: "headset")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Feedback", systemImage: "bubble.left.fill")
        }
    }

    // MARK: Footer
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

struct RowInSectionView: View {
    var label: String? = nil
    let title: String
    let systemImage: String
    var badgeCount: Int? = nil
    
    var onClicked: (() -> Void)?
    
    var body: some View {
        Button {
            onClicked?()
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
                
                VStack(alignment: .leading, spacing: 4) {
                    if let label = label {
                        Text(label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(title)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                if let count = badgeCount, count > 0 {
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
                
                if onClicked != nil {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
            .padding(.vertical, 12)
        }
        .disabled(onClicked == nil)
        .foregroundStyle(.primary)
    }
}

struct DeviderInSectionView: View {
    var padding: CGFloat = 50
    var body: some View {
        Divider().padding(.leading, padding)
    }
}
