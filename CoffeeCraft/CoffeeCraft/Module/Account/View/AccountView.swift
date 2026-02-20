//
//  AccountView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct AccountView: View {
//    @StateObject var inboxVM = InboxViewModel()
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var favVM: FavoriteViewModel
    @EnvironmentObject var announcementVM: AnnouncementViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var userSession: UserSession
    @Environment(\.pushScreen) var push
    @State var isOpenAddCard: Bool = false
    
    var body: some View {
        CustomRefreshScrollView( {
            VStack(spacing: 20) {
                profileSection
                myCardSection
                personalSection
                shortcutsSection
                contactsSection
//                Button("Seed Database") {s
//                    Task {
//                        await CustomizationSeeder.seedCustomizations()
//                        print("✅ Database seeded successfully!")
//                    }
//                }
                footerSection
            }
            .padding()
        }, onRefresh: {
            
        })
        .background(Color(.systemGroupedBackground))
        .customNavigationBar("Account") {
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("gearshape.fill")) {
               push(AnyView(SettingsView()
                .environmentObject(authVM)
                .environmentObject(themeManager)))
            }
        }
        .onAppear {
            if let userId = UserSession.shared.userId {
                // Always fetch on appear if user exists
                cardVM.setUser(userId: userId)
            }
        }
        .onChange(of: UserSession.shared.currentUser) { oldValue, newValue in
            if let userId = newValue?.id {
                // Reset and fetch when user changes (login/logout)
                cardVM.isActiveCardFetched = false
                cardVM.setUser(userId: userId)
            }
        }
//        .navigationDestination(isPresented: $isNavigateToInbox, destination: {
//
//        })
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
                Text(UserSession.shared.userName ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                PushLink {
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
    }
    
    // MARK: My Cards
    var myCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.headline)
                    .foregroundColor(Color.brown)
                Text("My Cards")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 4)
            
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    if cardVM.isLoading && cardVM.activeCard == nil {
                        // Loading state
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    } else if let activeCard = cardVM.activeCard {
                        // Single LoyaltyCard
                        FlippableCardView(
                            card: activeCard,  // Updated parameter
                            width: (UIScreen.main.bounds.width * 0.8) - 32
                        )
                    }
                    Spacer()
                    Button(action: {
                        push(AnyView(AllCardsView()
                            .environmentObject(cardVM)
                            .environmentObject(authVM)))
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .foregroundColor(Color.brown)
                            }
                            Text("See All")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    })
                }
                HStack {
                    Button(action: {
                        push(AnyView(EmptyView()))
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
                        isOpenAddCard = true
                    }, label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(Color.brown)
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
//            RowInSectionView(title: "Inbox", systemImage: "tray.fill",
//                             badgeCount: inboxVM.displayedAnnouncements.filter { !$0.isRead }.count) {
//                push(AnyView(InboxView().environmentObject(inboxVM)))
//            }
//            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Personalization", systemImage: "slider.horizontal.3")
            DeviderInSectionView(padding: 44)
            RowInSectionView(title: "Favorites", systemImage: "heart.fill") {
                push(AnyView(FavoriteView()
                    .environmentObject(favVM)))
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
                push(AnyView(AnnouncementsListView().environmentObject(announcementVM)))
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
                        .foregroundColor(Color.brown)
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
                                .fill(Color.red)
                        )
                }
                
                if onClicked != nil {
                    if trailingSystemImage != "" {
                        Image(systemName: trailingSystemImage)
                            .font(.headline)
                            .foregroundColor(Color.brown)
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
                    .foregroundColor(Color.brown)
            }
        }
    }
    private func openURL() {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}
