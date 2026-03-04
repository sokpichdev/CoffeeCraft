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
    @Environment(\.pushScreen) var push
    @State var isOpenAddCard: Bool = false
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 20) {
                profileSection
                walletSection
                myCardSection
                personalSection
                shortcutsSection
                contactsSection
//                Button("Seed Database") {s
//                    Task {
//                        await CustomizationSeeder.seedCustomizations()
//                    }
//                }
                footerSection
            }
            .padding()
        }, onRefresh: {
            if let userId = UserSession.shared.userId {
                cardVM.setUser(userId: userId, isRefresh: true)
            }
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Account") {
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("gearshape.fill")) {
               push(AnyView(SettingsView()
                .environmentObject(authVM)))
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
        .onChange(of: UserSession.shared.currentUser) { oldValue, newValue in
            if let userId = newValue?.id {
                // Reset and fetch when user changes (login/logout)
                cardVM.isActiveCardFetched = false
                cardVM.setUser(userId: userId)
            }
        }
        .sheet(isPresented: $isOpenAddCard) {
            CustomNavigationStack {
                AddCardView()
                    .environmentObject(cardVM)
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
                            colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.75), Color.accentPrimary.opacity(0.5)],
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
            .shadow(color: Color.accentPrimary.opacity(0.3), radius: 8, y: 4)
            
            VStack(spacing: 6) {
                Text(UserSession.shared.userName ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                PushLink {
                    if userSession.isLoggedIn {
                        ProfileView()
                            .environmentObject(authVM)
                    } else {
                        AuthView().environmentObject(authVM)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("View Profile")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundStyle(Color.accentPrimary)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)
        )
    }
    
    // MARK: Wallet
    var walletSection: some View {
        SettingsSection(title: "My Wallet", icon: "creditcard.fill") {
            RowInSectionView(label: walletVM.formattedBalance, title: "Wallet", systemImage: "creditcard.fill") {
                push(AnyView(WalletView()))
            }
        }
    }
    
    // MARK: My Cards
    var myCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.headline)
                    .foregroundColor(Color.accentPrimary)
                Text("My Cards")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 4)
            
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    let cardWidth = (UIScreen.main.bounds.width * 0.8) - 32
                    if userSession.isLoggedIn {
                        if cardVM.isRefreshing || (cardVM.isLoading && cardVM.activeCard == nil) {
                            ShimmerView(cornerRadius: 10)
                                .frame(width: cardWidth, height: cardWidth / (16 / 9))
                        } else if let activeCard = cardVM.activeCard {
                            // Single LoyaltyCard
                            FlippableCardView(card: activeCard, width: cardWidth)
                        }
                    } else {
                        PushLink {
                            AuthView().environmentObject(authVM)
                        } label: {
                            CardEmptyView(title: "Log in to see your cards", cardWidth: cardWidth)
                        }
                    }
                    Spacer()
                    PushLink {
                        if userSession.isLoggedIn {
                            AllCardsView()
                                .environmentObject(cardVM)
                                .environmentObject(authVM)
                        } else {
                            AuthView().environmentObject(authVM)
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .foregroundColor(Color.accentPrimary)
                            }
                            Text("See All")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                HStack {
                    Button(action: {
                        if userSession.isLoggedIn {
                            AlertManager.shared.showWarning(title: "Coming Soon", message: "This Feature will be coming soon.")
                        } else {
                            push(AnyView(AuthView().environmentObject(authVM)))
                        }
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(.brown))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "cart.badge.plus")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text("Purchase")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    })
                    Button(action: {
                        if userSession.isLoggedIn {
                            isOpenAddCard = true
                        } else {
                            push(AnyView(AuthView().environmentObject(authVM)))
                        }
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.textPrimary.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(Color.accentPrimary)
                            }
                            Text("Add")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    })
                }
            }
        }
    }
    // MARK: Personal
    var personalSection: some View {
        SettingsSection(title: "Personal", icon: "person.text.rectangle") {
            RowInSectionView(title: "Inbox", systemImage: "tray.fill", badgeCount: inboxVM.unreadCount) {
                if userSession.isLoggedIn {
                    push(AnyView(InboxView().environmentObject(inboxVM)))
                } else {
                    push(AnyView(AuthView().environmentObject(authVM)))
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Personalization", systemImage: "slider.horizontal.3")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Favorites", systemImage: "heart.fill") {
                if userSession.isLoggedIn {
                    push(AnyView(FavoriteView()
                        .environmentObject(favVM)))
                } else {
                    push(AnyView(AuthView().environmentObject(authVM)))
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Addresses", systemImage: "location.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Vouchers", systemImage: "ticket.fill", badgeCount: 2)
        }
    }
    
    // MARK: ShortCuts
    var shortcutsSection: some View {
        SettingsSection(title: "Shortcuts", icon: "bolt.fill") {
            RowInSectionView(title: "Stores", systemImage: "building.2.fill")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Announcements", systemImage: "megaphone.fill") {
                if userSession.isLoggedIn {
                    push(AnyView(AnnouncementsListView().environmentObject(announcementVM)))
                } else {
                    push(AnyView(AuthView().environmentObject(authVM)))
                }
            }
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Rewards", systemImage: "gift.fill")
        }
    }
    
    // MARK: contacts
    var contactsSection: some View {
        SettingsSection(title: "Contacts", icon: "bubble.left.and.bubble.right.fill") {
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

struct RowInSectionView: View {
    var label: String? = nil
    let title: String
    let systemImage: String
    var badgeCount: Int? = nil
    
    var trailingSystemImage: String = "chevron.right"
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
                        .foregroundColor(Color.accentPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let label = label {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(title)
                        .font(.subheadline)
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
                                .fill(Color.semanticError)
                        )
                }
                
                if onClicked != nil {
                    if trailingSystemImage != "" {
                        Image(systemName: trailingSystemImage)
                            .font(.headline)
                            .foregroundColor(Color.accentPrimary)
                    }
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

struct SocialMediaButton: View {
    let icon: String
    let url: String

    var body: some View {
        Button {
            openURL()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(Color.accentPrimary)
            }
        }
    }
    private func openURL() {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}
