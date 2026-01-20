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
    
    @Binding var selectedTab: Tab
    private let originalBanners = [
        "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        "https://i.postimg.cc/7hwm7VhT/image.png",
        "https://i.postimg.cc/Z5Wn4zHf/image.png",
        "https://i.postimg.cc/G903q40J/image.png"
    ]

    @State private var currentIndex: Int = 0
    let announcements = [
        Announcement(id: 1, title: "New Coffee Blend!", description: "Try our new seasonal coffee.", imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg", createdDate: ""),
        Announcement(id: 2, title: "Weekend Special", description: "Discount for all drinks this weekend.", imageName: "", createdDate: ""),
        Announcement(id: 3, title: "Free Cookie", description: "Get a free cookie with any coffee.", imageName: "", createdDate: "")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                
                // MARK: - Stretchy Header Banner
                GeometryReader { geo in
                    let minY = geo.frame(in: .global).minY
                    let baseHeight: CGFloat = 250
                    let dynamicHeight = baseHeight + (minY > 0 ? minY : 0)
                    
                    InfiniteCarousel(
                        items: originalBanners,
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
                        PageIndicator(count: originalBanners.count, currentIndex: currentIndex)
                            .padding(.bottom, 15), // Gap from the bottom of the image
                        alignment: .bottom
                    )
                    .offset(y: minY > 0 ? -minY : 0)
                }
                .frame(height: 250)
                
                VStack(spacing: 12) {

                    Text("Good Morning, \(authVM.currentUser?.name ?? "User")! ☀️")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        PickUpButton(onClick: { selectedTab = .menu })
                        PickUpButton(title: "Delivery") {}
                    }
                    .padding(.horizontal)

                    announcementLabel
                    
                    VStack(spacing: 20) {
                        ForEach(announcements.prefix(3)) { ann in
                            NavigationLink {
                                AnnouncementDetailView(announcement: ann)
                            } label: {
                                AnnouncementCardView(announcement: ann)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 30)
            }
        }
        .edgesIgnoringSafeArea(.top)
//        .task {
//            await ProductSeeder.seedSampleProducts()
//        }
    }
        
    var announcementLabel: some View {
        HStack {
            Text("Announcements")
                .font(.headline)
            
            Spacer()
            
            NavigationLink {
                AnnouncementsListView()
            } label: {
                Text("See All")
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
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

struct Announcement: Identifiable {
    let id: Int
    let title: String?
    let description: String?
    let imageName: String?
    let createdDate: String?
    var isRead: Bool = false
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
