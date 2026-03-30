//
//  AccountView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var favVM: FavoriteViewModel
    @EnvironmentObject var announcementVM: AnnouncementViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var walletVM: WalletViewModel

    @EnvironmentObject var userSession: UserSession
    @Binding var selectedTab: Tab
    @State var isOpenAddCard: Bool = false

    // Navigation state
    @State private var showSettings = false
    @State private var showWallet = false
    @State private var showInbox = false
    @State private var showColorTheme = false
    @State private var showFavorites = false
    @State private var showAnnouncements = false
    @State private var showAddresses = false
    @State private var showAuth = false
    @State private var showRewards = false
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 20) {
                ProfileSection()
                    .environmentObject(authVM)
                WalletSection(showWallet: $showWallet, showAuth: $showAuth)
                    .environmentObject(walletVM)
                MyCardSection(isOpenAddCard: $isOpenAddCard, showAuth: $showAuth)
                    .environmentObject(cardVM)
                    .environmentObject(authVM)
                PersonalSection(showInbox: $showInbox, showColorTheme: $showColorTheme,
                                showFavorites: $showFavorites, showAddresses: $showAddresses, showAuth: $showAuth)
                    .environmentObject(inboxVM)
                
                ShortcutsSection(showAnnouncements: $showAnnouncements, showRewards: $showRewards, showAuth: $showAuth)
                    .environmentObject(announcementVM)
                ContactsSection()
                FooterSection()
            }
            .padding()
        }, onRefresh: {
            if let userId = UserSession.shared.userId {
                cardVM.setUser(userId: userId, isRefresh: true)
            }
        })
        .background(Color.bgSecondary)
        .customNavigationBar("Account") {
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("gearshape.fill")) {
               showSettings = true
            }
        }
        .onAppear {
            if let userId = UserSession.shared.userId {
                walletVM.setup(userId: userId)
                if cardVM.cards.isEmpty {
                    cardVM.setUser(userId: userId)
                }
            }
        }
        .onChange(of: UserSession.shared.currentUser) { _, newValue in
            if let userId = newValue?.id {
                cardVM.isActiveCardFetched = false
                cardVM.setUser(userId: userId)
            }
        }
        .sheet(isPresented: $isOpenAddCard) {
            NavigationStack {
                AddCardView()
                    .environmentObject(cardVM)
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView().environmentObject(authVM)
        }
        .navigationDestination(isPresented: $showWallet) {
            WalletView()
                .environmentObject(walletVM)
        }
        .navigationDestination(isPresented: $showInbox) {
            InboxView().environmentObject(inboxVM)
        }
        .navigationDestination(isPresented: $showColorTheme) {
            ColorThemePickerView()
        }
        .navigationDestination(isPresented: $showFavorites) {
            FavoriteView(selectedTab: $selectedTab).environmentObject(favVM)
        }
        .navigationDestination(isPresented: $showAnnouncements) {
            AnnouncementsListView().environmentObject(announcementVM)
        }
        .navigationDestination(isPresented: $showAddresses) {
            SavedLocationsView()
        }
        .navigationDestination(isPresented: $showAuth) {
            AuthView().environmentObject(authVM)
        }
        .navigationDestination(isPresented: $showRewards) {
            RewardsView().environmentObject(cardVM)
        }
    }
}

// MARK: - Wallet Section
struct WalletSection: View {
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var userSession: UserSession
    @Binding var showWallet: Bool
    @Binding var showAuth: Bool
    
    var body: some View {
        SettingsSection(title: "My Wallet", icon: "creditcard.fill") {
            RowInSectionView(label: walletVM.formattedBalance, title: "Wallet", systemImage: "creditcard.fill") {
                if userSession.isLoggedIn {
                    showWallet = true
                } else {
                    showAuth = true
                }
            }
        }
    }
}

// MARK: - Personal Section
struct PersonalSection: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var userSession: UserSession
    @Binding var showInbox: Bool
    @Binding var showColorTheme: Bool
    @Binding var showFavorites: Bool
    @Binding var showAddresses: Bool
    @Binding var showAuth: Bool
    
    var body: some View {
        SettingsSection(title: "Personal", icon: "person.text.rectangle") {
            RowInSectionView(title: "Inbox", systemImage: "tray.fill", badgeCount: inboxVM.unreadCount) {
                if userSession.isLoggedIn {
                    showInbox = true
                } else {
                    showAuth = true
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Color Theme", systemImage: "paintpalette.fill") {
                if userSession.isLoggedIn {
                    showColorTheme = true
                } else {
                    showAuth = true
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Personalization", systemImage: "slider.horizontal.3")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Favorites", systemImage: "heart.fill") {
                if userSession.isLoggedIn {
                    showFavorites = true
                } else {
                    showAuth = true
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Addresses", systemImage: "location.fill") {
                if userSession.isLoggedIn {
                    showAddresses = true
                } else {
                    showAuth = true
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Vouchers", systemImage: "ticket.fill")
        }
    }
}

// MARK: - Shortcuts Section
struct ShortcutsSection: View {
    @EnvironmentObject var announcementVM: AnnouncementViewModel
    @EnvironmentObject var userSession: UserSession
    @Binding var showAnnouncements: Bool
    @Binding var showRewards: Bool
    @Binding var showAuth: Bool

    var body: some View {
        SettingsSection(title: "Shortcuts", icon: "bolt.fill") {
            RowInSectionView(title: "Stores", systemImage: "building.2.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Announcements", systemImage: "megaphone.fill") {
                if userSession.isLoggedIn {
                    showAnnouncements = true
                } else {
                    showAuth = true
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Rewards", systemImage: "gift.fill") {
                if userSession.isLoggedIn {
                    showRewards = true
                } else {
                    showAuth = true
                }
            }
        }
    }
}

// MARK: - Contacts Section
struct ContactsSection: View {
    var body: some View {
        SettingsSection(title: "Contacts", icon: "bubble.left.and.bubble.right.fill") {
            RowInSectionView(title: "Customer Service", systemImage: "headset")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Feedback", systemImage: "bubble.left.fill")
        }
    }
}

// MARK: - Footer Section
struct FooterSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Stay connected with us")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 20) {
                SocialMediaButton(icon: "play.rectangle.fill", url: "")
                SocialMediaButton(icon: "music.note", url: "")
                SocialMediaButton(icon: "camera.fill", url: "")
                SocialMediaButton(icon: "link", url: "")
            }
        }
        .padding(.vertical, 20)
        .padding(.top, 8)
    }
}

struct DeviderInSectionView: View {
    var padding: CGFloat = 50
    var body: some View {
        Divider().padding(.leading, padding)
    }
}

struct SocialMediaButton: View {
    let icon: String
    let url: String

    var body: some View {
        if !url.isEmpty {
            Button {
                openURL()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.surfacePrimary)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.headline)
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
    }

    private func openURL() {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}
