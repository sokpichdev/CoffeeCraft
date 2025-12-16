//
//  HomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

struct HomeView: View {
    @State private var selectedBanner = 0
    let banners = ["", "", "", ""]
    let announcements = [
        Announcement(id: 1, title: "New Coffee Blend!", description: "Try our new seasonal coffee.", imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg"),
        Announcement(id: 2, title: "Weekend Special", description: "Discount for all drinks this weekend.", imageName: ""),
        Announcement(id: 3, title: "Free Cookie", description: "Get a free cookie with any coffee.", imageName: "")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                TabView(selection: $selectedBanner) {
                    ForEach(0..<banners.count, id: \.self) { index in
                        AsyncImageCard(imageURL: banners[index], height: 180, width: UIScreen.main.bounds.width, corner: 0)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 180)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                        withAnimation {
                            selectedBanner = (selectedBanner + 1) % banners.count
                        }
                    }
                }
                
                Text("Good Morning, Sok! ☀️")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    PickUpButton() {}
                    PickUpButton(title: "Delivery") {}
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Announcements")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                    }) {
                        Text("See All")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
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
}

struct PickUpButton: View {
    var title: String = "Pickup"
    var onClick: (() -> Void)?
    
    var body: some View {
        Button(action: { onClick?() }) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}

struct Announcement: Identifiable {
    let id: Int
    let title: String?
    let description: String?
    let imageName: String?
}
