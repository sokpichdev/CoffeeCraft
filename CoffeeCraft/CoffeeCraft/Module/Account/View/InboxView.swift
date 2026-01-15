//
//  InboxView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(announcements) { announcement in
                    NavigationLink {
                        AnnouncementDetailView(announcement: announcement)
                    } label: {
                        InboxItemView(announcement: announcement)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Inbox", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Mark all as read action
                } label: {
                    Text("Mark All Read")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
    }
}

import SDWebImageSwiftUI

struct InboxItemView: View {
    let announcement: Announcement
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon/Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.brown, Color.brown.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                if let imageUrl = announcement.imageName {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .indicator(.activity)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if let title = announcement.title {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Unread indicator
                    Circle()
                        .fill(Color(red: 0.55, green: 0.35, blue: 0.18))
                        .frame(width: 8, height: 8)
                }
                
                if let description = announcement.description {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                if let createdDate = announcement.createdDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(createdDate)
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        )
    }
}

// static mock data
let announcements: [Announcement] = [
    Announcement(
        id: 1,
        title: "New Year Promotion! ☕",
        description: "Celebrate 2026 with 20% off all beverages. Valid until January 31st. Don't miss out on your favorite coffee!",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 hours ago"
    ),
    Announcement(
        id: 2,
        title: "Loyalty Program Update",
        description: "Earn double points on all purchases this week! Check your rewards balance and redeem exciting offers.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 day ago"
    ),
    Announcement(
        id: 3,
        title: "New Menu Items Available",
        description: "Try our seasonal winter collection featuring Caramel Macchiato Supreme and Hazelnut Dream Latte.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 days ago"
    ),
    Announcement(
        id: 4,
        title: "Store Hours Update",
        description: "Our downtown location will be open extended hours starting next week - 6 AM to 10 PM daily.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "3 days ago"
    ),
    Announcement(
        id: 5,
        title: "Free Pastry Day Tomorrow!",
        description: "Buy any large beverage and get a complimentary pastry of your choice. One per customer.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "5 days ago"
    ),
    Announcement(
        id: 6,
        title: "App Update Available",
        description: "Version 2.0 is here with improved ordering, faster checkout, and exclusive app-only deals.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 week ago"
    ),
    Announcement(
        id: 7,
        title: "Sustainability Initiative",
        description: "Bring your reusable cup and get 10% off! Join us in reducing single-use plastics.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 week ago"
    ),
    Announcement(
        id: 8,
        title: "Customer Appreciation Event",
        description: "Thank you for your loyalty! Join us this Saturday for special tastings and giveaways.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 weeks ago"
    ),
    Announcement(
        id: 9,
        title: "Weekend Special Offer",
        description: "Get 2 for 1 on all iced drinks this Saturday and Sunday. Perfect for sharing with friends!",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 weeks ago"
    ),
    Announcement(
        id: 10,
        title: "Barista Training Session",
        description: "Want to learn latte art? Join our free workshop next Friday at 5 PM. Limited spots available!",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "3 weeks ago"
    ),
    Announcement(
        id: 11,
        title: "Mobile Order & Pay Launch",
        description: "Skip the line! Order ahead through our app and pick up your coffee without waiting.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "3 weeks ago"
    ),
    Announcement(
        id: 12,
        title: "Birthday Rewards Program",
        description: "Celebrate your special day with a free drink of your choice! Register your birthday in the app.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 month ago"
    ),
    Announcement(
        id: 13,
        title: "Introducing Cold Brew Collection",
        description: "Our new cold brew lineup features unique flavors like Vanilla Bean and Salted Caramel.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 month ago"
    ),
    Announcement(
        id: 14,
        title: "Student Discount Available",
        description: "Show your student ID and get 15% off all purchases Monday through Friday.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 month ago"
    ),
    Announcement(
        id: 15,
        title: "Coffee Bean Sale",
        description: "Take home your favorite beans! 25% off all retail coffee bags this week only.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "1 month ago"
    ),
    Announcement(
        id: 16,
        title: "New Store Opening Soon",
        description: "We're expanding! Our new riverside location opens next month. Stay tuned for grand opening details.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 months ago"
    ),
    Announcement(
        id: 17,
        title: "Refer a Friend Bonus",
        description: "Share the love! Refer friends and you both get $5 credit when they make their first purchase.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 months ago"
    ),
    Announcement(
        id: 18,
        title: "Happy Hour Deal",
        description: "All espresso drinks are $1 off from 2-4 PM daily. Perfect afternoon pick-me-up!",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 months ago"
    ),
    Announcement(
        id: 19,
        title: "Gift Cards Now Available",
        description: "The perfect gift for coffee lovers! Purchase digital or physical gift cards through the app.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 months ago"
    ),
    Announcement(
        id: 20,
        title: "Seasonal Menu Preview",
        description: "Get a sneak peek at our spring menu! Lavender Honey Latte and Strawberry Matcha coming soon.",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "3 months ago"
    )
]
