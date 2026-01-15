//
//  AnnouncementsListView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/18/25.
//
import SwiftUI

struct AnnouncementsListView: View {

    private let announcements: [Announcement] = [
        Announcement(
            id: 1,
            title: "New Coffee Blend!",
            description: "Try our brand new seasonal coffee blend, carefully sourced and roasted for a smooth, rich flavor.",
            imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg", createdDate: ""
        ),
        Announcement(
            id: 2,
            title: "Weekend Special ☕️",
            description: "Enjoy 20% off all drinks this weekend. Perfect time to grab your favorite coffee!",
            imageName: "https://i.postimg.cc/7hwm7VhT/image.png", createdDate: ""
        ),
        Announcement(
            id: 3,
            title: "Free Cookie with Coffee 🍪",
            description: "Get a free cookie with any coffee purchase. Limited time only!",
            imageName: "https://i.postimg.cc/Z5Wn4zHf/image.png", createdDate: ""
        ),
        Announcement(
            id: 4,
            title: "Happy Hour is Back!",
            description: "Buy 1 Get 1 Free on all iced drinks from 3 PM to 5 PM daily.",
            imageName: "https://i.postimg.cc/G903q40J/image.png", createdDate: ""
        ),
        Announcement(
            id: 5,
            title: "New Store Opening 🎉",
            description: "We’re excited to announce the opening of our new branch near you. Visit us this week!",
            imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg", createdDate: ""
        ),
        Announcement(
            id: 6,
            title: "Loyalty Program Update ⭐️",
            description: "Earn double points on all purchases this month. Don’t miss out on rewards!",
            imageName: "https://i.postimg.cc/7hwm7VhT/image.png", createdDate: ""
        ),
        Announcement(
            id: 7,
            title: "Limited Edition Mug",
            description: "Collect our new limited-edition coffee mugs, available while stocks last.",
            imageName: "https://i.postimg.cc/Z5Wn4zHf/image.png", createdDate: ""
        ),
        Announcement(
            id: 8,
            title: "Early Bird Discount 🌅",
            description: "Get 10% off any coffee before 9 AM. Start your day right!",
            imageName: "https://i.postimg.cc/G903q40J/image.png", createdDate: ""
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(announcements) { ann in
                    NavigationLink {
                        AnnouncementDetailView(announcement: ann)
                    } label: {
                        AnnouncementCardView(announcement: ann)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle("Announcements")
        .navigationBarTitleDisplayMode(.large)
    }
}
