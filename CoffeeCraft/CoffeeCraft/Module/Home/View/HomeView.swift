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
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var selectedTab: Tab
    @State private var currentIndex: Int = 0
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
                await announcementVM.fetchAnnouncements()
            }
        })
        .edgesIgnoringSafeArea(.top)
        .background(Color.bgPrimary)
        .onAppear {
            if !announcementVM.isAnnouncementsFetched {
                Task {
                    await announcementVM.fetchAnnouncements()
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
                    Color.accentPrimary.opacity(0.08)
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 44))
                            .foregroundColor(Color.accentPrimary.opacity(0.4))
                        Text("No Banners Available")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.accentPrimary.opacity(0.6))
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
                        .foregroundColor(.textSecondary)
                    Text(UserSession.shared.userName ?? "Coffee Lover")
                        .font(.title3).fontWeight(.bold).fontDesign(.serif)
                        .foregroundColor(Color.textPrimary)
                }
                Spacer()
            }

            // Balance + Points + Top Up row
            if UserSession.shared.isLoggedIn {
                HStack(spacing: 10) {
                    NavigationLink {
                        WalletView(showWallet: false)
                            .environmentObject(walletVM)
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
                        .foregroundColor(Color.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.accentPrimary.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1))
                    }
                    // Points pill
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(cardVM.activeCard?.points ?? 0) pts")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(Color.accentGold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.accentGold.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.accentGold.opacity(0.2), lineWidth: 1))

                    Spacer()

                    // Top Up button
                    NavigationLink {
                        TopUpView(walletVM: walletVM)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Top Up")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.textPrimary).colorScheme(.dark)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(
                                colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.accentPrimary.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.surfacePrimary.opacity(0.05), radius: 8, y: 3)
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

    private var seeAllLabel: some View {
        HStack(spacing: 6) {
            Text("See All")
                .font(.subheadline.weight(.semibold))
            Image(systemName: "arrow.right")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundColor(Color.textPrimary)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.surfaceSub)
        )
        .overlay(
            Capsule()
                .stroke(Color.accentPrimary.opacity(0.5), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
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
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(announcementVM.announcements.prefix(3)) { ann in
                    NavigationLink {
                        if UserSession.shared.isLoggedIn {
                            AnnouncementDetailView(announcement: ann)
                        } else {
                            AuthView().environmentObject(authVM)
                        }
                    } label: {
                        AnnouncementCardView(announcement: ann)
                    }
                }

                NavigationLink {
                    if UserSession.shared.isLoggedIn {
                        AnnouncementsListView().environmentObject(announcementVM)
                    } else {
                        AuthView().environmentObject(authVM)
                    }
                } label: {
                    seeAllLabel
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
                .foregroundColor(Color.textSecondary)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.textPrimary)
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
                        .fill(Color.textPrimary.opacity(isDisabled ? 0.4 : 0.25))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isDisabled ? Color.textPrimary.opacity(0.5) : .textPrimary)
                }

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isDisabled ? Color.textPrimary.opacity(0.5) : .textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isDisabled ? Color.textPrimary.opacity(0.4) : Color.textPrimary.opacity(0.8))
            }
            .colorScheme(.dark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.accentPrimary.opacity(isDisabled ? 0.05 : 0.3),
                        radius: 8, x: 0, y: 4
                    )
                    .colorScheme(.light)
            )
            .overlay(
                Group {
                    if isDisabled {
                        Text("Coming Soon")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.accentPrimary)
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
                    .fill(index == currentIndex ? Color.accentPrimary : Color.textPrimary.opacity(0.75))
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
        .background(Capsule().fill(Color.textPrimary.opacity(0.3)))
        .colorScheme(.dark)
        .accessibilityValue("Slide \(currentIndex + 1) of \(count)")
    }
}

// MARK: - Sticky Banner Extension (kept for future use)
extension HomeView {
    var headerBannerStickyView: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let baseHeight: CGFloat = 260
            let dynamicHeight = baseHeight + (minY > 0 ? minY : 0)

            if !bannerImages.isEmpty {
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
                    PageIndicator(count: bannerImages.count, currentIndex: currentIndex),
                    alignment: .bottom
                )
                .offset(y: minY > 0 ? -minY : 0)
            } else {
                ZStack {
                    Color.accentPrimary.opacity(0.08)
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 44))
                            .foregroundColor(Color.accentPrimary.opacity(0.4))
                        Text("No Banners Available")
                            .font(.subheadline)
                            .foregroundColor(Color.accentPrimary.opacity(0.6))
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
