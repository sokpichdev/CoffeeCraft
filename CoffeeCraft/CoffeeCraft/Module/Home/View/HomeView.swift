//
//  HomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var announcementVM = AnnouncementViewModel()
    @Binding var selectedTab: Tab
    @State private var currentIndex: Int = 0
    private var bannerImages: [String] {
        announcementVM.announcements
            .prefix(4)
            .compactMap { $0.imageName }
            .filter { !$0.isEmpty }
    }
    @Environment(\.pushScreen) var push
    var body: some View {
        CustomRefreshScrollView( {
            VStack(alignment: .leading, spacing: 10) {
                if announcementVM.isLoading {
                    ShimmerView(cornerRadius: 0).frame(height: 250)
                } else {
                    headerBannerView
                }
                VStack(spacing: 12) {

                    Text("Good Morning, \(UserSession.shared.userName ?? "User")! ☀️")
                        .font(.app(.LibreBaskerville, weight: .bold, size: 22))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        PickUpButton(onClick: { selectedTab = .menu })
                        PickUpButton(title: "Delivery") {
                            LoaderManager.shared.showLoading(autoHide: true, delay: 10)
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 6) {
                        announcementLabel
                        
                        if announcementVM.isLoading {
                            VStack {
                                ForEach(0..<3) { _ in
                                    AnnouncementCardShimmerView()
                                }
                            }
                        } else if announcementVM.announcements.isEmpty {
                            Text("No announcements yet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            VStack {
                                ForEach(announcementVM.announcements.prefix(3)) { ann in
                                    Button(action: {
                                        push(AnyView(AnnouncementDetailView(announcement: ann)))
                                    }, label: {
                                        AnnouncementCardView(announcement: ann)
                                    })
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 30)
            }
        }, onRefresh: {
            Task {
                try? await announcementVM.fetchAnnouncements()
            }
        })
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if !announcementVM.isAnnouncementsFetched {
                Task {
                    try? await announcementVM.fetchAnnouncements()
                }
            }
        }
    }
    
    var headerBannerView: some View {
        Group {
            let height: CGFloat = 250
            
            if bannerImages.count > 0 {
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
                .overlay(
                    PageIndicator(count: bannerImages.count, currentIndex: currentIndex)
                        .padding(.bottom, 15),
                    alignment: .bottom
                )
                .frame(height: height)
                .clipped()
            } else {
                ZStack {
                    Color.coffeeBrown.opacity(0.1)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.coffeeBrown.opacity(0.5))
                        
                        Text("No Banners Available")
                            .font(.headline)
                            .foregroundColor(.coffeeBrown.opacity(0.7))
                    }
                }
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
            }
        }
        .frame(height: 250)
    }
    
    var announcementLabel: some View {
        HStack {
            Text("Announcements")
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                push(AnyView(AnnouncementsListView()
                    .environmentObject(announcementVM)))
            }, label: {
                Text("See All")
                    .font(.headline)
                    .padding(8)
            })
            .buttonStyle(.plain)
        }
    }
}
struct PickUpButton: View {
    var title: String = "Pickup"
    var onClick: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onClick?()
        }, label: {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Color.brown)
                .cornerRadius(15)
        })
        .foregroundColor(.white)
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    }
}

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.brown : Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .frame(
                        width: index == currentIndex ? 18 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }
}

extension HomeView {
    var headerBannerStickyView: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let baseHeight: CGFloat = 250
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
                    Color.coffeeBrown.opacity(0.1)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.coffeeBrown.opacity(0.5))
                        
                        Text("No Banners Available")
                            .font(.headline)
                            .foregroundColor(.coffeeBrown.opacity(0.7))
                    }
                }
                .frame(height: dynamicHeight)
                .frame(maxWidth: .infinity)
                .offset(y: minY > 0 ? -minY : 0)
            }
        }
        .frame(height: 250)
    }
}
