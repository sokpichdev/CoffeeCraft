//
//  HomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

struct HomeView: View {
    private let banners = ["https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
                           "https://i.postimg.cc/7hwm7VhT/image.png",
                           "https://i.postimg.cc/Z5Wn4zHf/image.png",
                           "https://i.postimg.cc/G903q40J/image.png"]
    private var loopedBanners: [String] {
        banners + banners + banners + banners
    }
    
    @State private var selectedBanner: Int = 0
    @State private var bannerTimer: Timer?
    @State private var resumeWorkItem: DispatchWorkItem?
    @State private var isUserDragging = false
    let announcements = [
        Announcement(id: 1, title: "New Coffee Blend!", description: "Try our new seasonal coffee.", imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg"),
        Announcement(id: 2, title: "Weekend Special", description: "Discount for all drinks this weekend.", imageName: ""),
        Announcement(id: 3, title: "Free Cookie", description: "Get a free cookie with any coffee.", imageName: "")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                bannerCarousel
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
        .onAppear {
            selectedBanner = banners.count
            startBannerTimer()
        }
        .onDisappear {
            bannerTimer?.invalidate()
            bannerTimer = nil
            resumeWorkItem?.cancel()
        }
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

extension HomeView {
    private var bannerCarousel: some View {
        VStack(spacing: 8) {

            TabView(selection: $selectedBanner) {
                ForEach(loopedBanners.indices, id: \.self) { index in
                    AsyncImageCard(
                        imageURL: loopedBanners[index],
                        height: 180,
                        width: UIScreen.main.bounds.width,
                        corner: 0
                    )
                    .tag(index)
                    .allowsHitTesting(false)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 180)
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        pauseAutoScroll()
                    }
                    .onEnded { _ in
                        resumeAutoScrollAfterDelay()
                    }
            )
            .onChange(of: selectedBanner, perform: handleInfiniteLoop)

            // Custom page indicator
            pageIndicator
        }
    }

    private func handleInfiniteLoop(_ index: Int) {
        let count = banners.count

        // reached end → reset to middle silently
        if index == count * 2 {
            DispatchQueue.main.async {
                selectedBanner = count
            }
        }
    }

    private func startBannerTimer() {
        bannerTimer?.invalidate()

        bannerTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            guard !isUserDragging else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                selectedBanner += 1
            }
        }
    }
    private func pauseAutoScroll() {
        isUserDragging = true
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    private func resumeAutoScrollAfterDelay() {
        resumeWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            isUserDragging = false
            startBannerTimer()
        }

        resumeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: workItem)
    }
    private var realIndex: Int {
        selectedBanner % banners.count
    }
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<banners.count, id: \.self) { index in
                Capsule()
                    .fill(index == realIndex ? Color.brown : Color.gray.opacity(0.4))
                    .frame(
                        width: index == realIndex ? 16 : 6,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.25), value: realIndex)
            }
        }
        .padding(.top, 6)
    }

}
