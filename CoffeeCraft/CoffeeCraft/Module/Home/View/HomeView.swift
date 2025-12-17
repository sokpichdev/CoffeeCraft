//
//  HomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI
import SDWebImage

// MARK: - HomeView
struct HomeView: View {
    // 1. Data
    private let originalBanners = [
        "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        "https://i.postimg.cc/7hwm7VhT/image.png",
        "https://i.postimg.cc/Z5Wn4zHf/image.png",
        "https://i.postimg.cc/G903q40J/image.png"
    ] // N = 4 (Real items)

    // 2. Looping Data (Buffer: [D, A, B, C, D, A] -> 6 items)
    private var loopedBanners: [String] {
        guard let first = originalBanners.first, let last = originalBanners.last else { return originalBanners }
        var temp = [String]()
        temp.append(last)               // Index 0: Duplicate of last
        temp.append(contentsOf: originalBanners) // Index 1 to N: Real items
        temp.append(first)              // Index N+1: Duplicate of first
        return temp
    }

    // 3. State bound to the TabView (0 to N+1)
    @State private var currentIndex: Int = 0 // Tracks the real 0-3 index
    // Timer state for auto-scrolling
    @State private var autoScrollTimer: Timer?
    
    // Other data
    let announcements = [
        Announcement(id: 1, title: "New Coffee Blend!", description: "Try our new seasonal coffee.", imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg"),
        Announcement(id: 2, title: "Weekend Special", description: "Discount for all drinks this weekend.", imageName: ""),
        Announcement(id: 3, title: "Free Cookie", description: "Get a free cookie with any coffee.", imageName: "")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(spacing: 8) {
                    GenericInfiniteCarousel(
                        items: originalBanners,
                        height: 180,
                        viewWidth: UIScreen.main.bounds.width,
                        currentIndex: $currentIndex
                    ) { urlString in
                        AsyncImageCard(imageURL: urlString, height: 180, width: UIScreen.main.bounds.width, corner: 0)
                    }
                    .frame(height: 180)
                    
                    PageIndicator(
                            count: originalBanners.count,
                            currentIndex: currentIndex
                        )
                }
                
                Spacer().frame(height: 10)
                
                Text("Good Morning, Sok! ☀️")
                    .font(.customTitle2.bold())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    PickUpButton(onClick: { })
                    PickUpButton(title: "Delivery") {}
                }
                .padding(.horizontal)
                .zIndex(1)
                announcementLabel
                
                VStack(spacing: 20) {
                    ForEach(announcements.prefix(3), id: \.id) { ann in
                        AnnouncementCardView(announcement: ann) {}
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
        
    var announcementLabel: some View {
        HStack {
            Text("Announcements")
                .font(.customHeadline)
            Spacer()
            Button(action: {
                print("See All button clicked!")
            }) {
                Text("See All")
                    .foregroundColor(.blue)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
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
}

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.brown : Color.gray.opacity(0.3))
                    .frame(
                        width: index == currentIndex ? 18 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }
}
