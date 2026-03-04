//
//  HomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var announcementVM: AnnouncementViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var cardVM: CardViewModel
    @Binding var selectedTab: Tab
    @State private var currentIndex: Int = 0
    @State private var showTopUp: Bool = false
    private var bannerImages: [String] {
        announcementVM.announcements
            .prefix(4)
            .compactMap { $0.imageName }
            .filter { !$0.isEmpty }
    }
    var body: some View {
        CustomRefreshScrollView(loaderOffset: 20, {
            VStack(alignment: .leading, spacing: 0) {

                bannerSection
                    .padding(.bottom, 20)

                greetingCard
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                quickOrderSection
                    .padding(.horizontal)
                    .padding(.bottom, 24)

                announcementsSection
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }, onRefresh: {
            Task {
                try? await announcementVM.fetchAnnouncements()
            }
        })
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showTopUp) {
            TopUpView(walletVM: walletVM)
        }
        .onAppear {
            if !announcementVM.isAnnouncementsFetched {
                Task {
                    try? await announcementVM.fetchAnnouncements()
                }
            }
        }
    }

    private var bannerSection: some View {
        Group {
            let height: CGFloat = UIScreen.main.bounds.width * 9 / 16

            if announcementVM.isLoading {
                ShimmerView(cornerRadius: 0).frame(height: height)
            } else if bannerImages.isEmpty {
                ZStack {
                    Color.coffeeBrown.opacity(0.08)
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 44))
                            .foregroundColor(Color.coffeeBrown.opacity(0.4))
                        Text("No Banners Available")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.coffeeBrown.opacity(0.6))
                    }
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
            } else {
                ZStack(alignment: .bottom) {
                    InfiniteCarousel(
                        items: bannerImages,
                        height: height,
                        width: UIScreen.main.bounds.width,
                        currentIndex: $currentIndex
                    ) { urlString in
                        AsyncImageCard(
                            imageURL: urlString,
                            height: height,
                            width: UIScreen.main.bounds.width,
                            corner: 0
                        )
                    }
                    .frame(height: height)
                    .clipped()

                    PageIndicator(count: bannerImages.count, currentIndex: currentIndex)
                        .padding(.bottom, 18)
                }
                .frame(height: height)
            }
        }
    }
    
    private var greetingCard: some View {
        VStack(spacing: 12) {
            // Name + greeting row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greetingText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(UserSession.shared.userName ?? "Coffee Lover")
                        .font(.title3).fontWeight(.bold).fontDesign(.serif)
                        .foregroundColor(Color.brown)
                }
                Spacer()
            }

            // Balance + Points + Top Up row
            if UserSession.shared.isLoggedIn {
                HStack(spacing: 10) {
                    PushLink {
                        FilteredTransactionView(transactions: walletVM.transactions, isLoading: walletVM.isLoading)
                    } label: {
                        // CC Balance pill
                        HStack(spacing: 5) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 11, weight: .semibold))
                            if walletVM.isLoading && walletVM.wallet == nil {
                                ShimmerView(cornerRadius: 6)
                                    .frame(width: 48, height: 14)
                            } else {
                                Text(walletVM.formattedBalance)
                                    .font(.system(size: 13, weight: .bold))
                                    .contentTransition(.numericText())
                                    .animation(.spring(duration: 0.4), value: walletVM.wallet?.balance)
                            }
                        }
                        .foregroundStyle(Color.coffeeBrown)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.coffeeBrown.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.coffeeBrown.opacity(0.2), lineWidth: 1))

                    }
                    // Points pill
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(cardVM.activeCard?.points ?? 0) pts")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.orange.opacity(0.2), lineWidth: 1))

                    Spacer()

                    // Top Up button
                    Button {
                        showTopUp = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Top Up")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(
                                colors: [Color.coffeeBrown, Color.coffeeLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.coffeeBrown.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning ☀️ Your brew awaits"
        case 12..<17: return "Good afternoon ☁️ Take a coffee break"
        case 17..<21: return "Good evening 🌙 Wind down with a cup"
        default: return "Hello! 🌙 Late night coffee?"
        }
    }

    private var quickOrderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Order", icon: "cart.fill")

            HStack(spacing: 14) {
                CozyOrderButton(
                    title: "Pickup",
                    subtitle: "Ready in minutes",
                    icon: "bag.fill"
                ) {
                    selectedTab = .menu
                }

                CozyOrderButton(
                    title: "Delivery",
                    subtitle: "Coming Soon",
                    icon: "bicycle",
                    isDisabled: true
                ) {
                    AlertManager.shared.showWarning(
                        title: "Stay Tuned",
                        message: "This Feature is Coming Soon."
                    )
                }
            }
        }
    }

    private var announcementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Announcements", icon: "megaphone.fill")

            if announcementVM.isLoading {
                ForEach(0..<3) { _ in
                    AnnouncementCardShimmerView()
                }
            } else if announcementVM.announcements.isEmpty {
                Text("No announcements yet — check back soon!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(announcementVM.announcements.prefix(3)) { ann in
                    PushLink {
                        if UserSession.shared.isLoggedIn {
                            AnnouncementDetailView(announcement: ann)
                        } else {
                            AuthView().environmentObject(AuthViewModel())
                        }
                    } label: {
                        AnnouncementCardView(announcement: ann)
                    }
                }

                PushLink {
                    if UserSession.shared.isLoggedIn {
                        AnnouncementsListView().environmentObject(announcementVM)
                    } else {
                        AuthView().environmentObject(AuthViewModel())
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("See All")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(Color.brown)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.brown.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.brown.opacity(0.25), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.brown)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.primary)
            Spacer()
        }
    }
}

// MARK: - Cozy Order Button
struct CozyOrderButton: View {
    let title: String
    let subtitle: String
    let icon: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(isDisabled ? 0.4 : 0.25))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isDisabled ? Color.white.opacity(0.5) : .white)
                }

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isDisabled ? Color.white.opacity(0.5) : .white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isDisabled ? Color.white.opacity(0.4) : Color.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.coffeeBrown, Color.coffeeBrown.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(
                color: Color.coffeeBrown.opacity(isDisabled ? 0.05 : 0.3),
                radius: 8, x: 0, y: 4
            )
            .overlay(
                Group {
                    if isDisabled {
                        Text("Coming Soon")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color.coffeeBrown)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white.opacity(0.85)))
                            .padding(10)
                    }
                },
                alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.coffeeBrown : Color.white.opacity(0.75))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .frame(
                        width: index == currentIndex ? 20 : 7,
                        height: 7
                    )
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.black.opacity(0.12)))
    }
}

// MARK: - Sticky Banner Extension (kept for future use)
extension HomeView {
    var headerBannerStickyView: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let baseHeight: CGFloat = 260
            let dynamicHeight = baseHeight + (minY > 0 ? minY : 0)

            if bannerImages.count > 0 {
                InfiniteCarousel(
                    items: bannerImages,
                    height: dynamicHeight,
                    width: UIScreen.main.bounds.width,
                    currentIndex: $currentIndex
                ) { urlString in
                    AsyncImageCard(
                        imageURL: urlString,
                        height: dynamicHeight,
                        width: UIScreen.main.bounds.width,
                        corner: 0
                    )
                }
                .overlay(
                    PageIndicator(count: bannerImages.count, currentIndex: currentIndex)
                        .padding(.bottom, 15),
                    alignment: .bottom
                )
                .offset(y: minY > 0 ? -minY : 0)
            } else {
                ZStack {
                    Color.coffeeBrown.opacity(0.08)
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 44))
                            .foregroundColor(Color.coffeeBrown.opacity(0.4))
                        Text("No Banners Available")
                            .font(.subheadline)
                            .foregroundColor(Color.coffeeBrown.opacity(0.6))
                    }
                }
                .frame(height: dynamicHeight)
                .frame(maxWidth: .infinity)
                .offset(y: minY > 0 ? -minY : 0)
            }
        }
        .frame(height: 260)
    }
}
