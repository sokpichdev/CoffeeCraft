//
//  InboxView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inboxVM: InboxViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach($inboxVM.displayedAnnouncements) { $announcement in
                    NavigationLink {
                        AnnouncementDetailView(announcement: announcement)
                            .onAppear {
                                inboxVM.markAsRead(id: announcement.id)
                            }
                    } label: {
                        InboxItemView(announcement: announcement)
                            .onAppear {
                                if announcement.id == inboxVM.displayedAnnouncements.last?.id {
                                    inboxVM.loadMore()
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Loading indicator
                if inboxVM.isLoading {
                    ProgressView()
                        .padding()
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
                    inboxVM.markAllAsRead()
                } label: {
                    Text("Mark All Read")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                }
            }
        }
        .onAppear {
            inboxVM.loadInitial()
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
                    if !announcement.isRead {
                        Circle()
                            .fill(Color(red: 0.55, green: 0.35, blue: 0.18))
                            .frame(width: 8, height: 8)
                    }

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
let announcements: [Announcement] = (1...100).map { id in
    Announcement(
        id: id,
        title: "New Year Promotion! ☕",
        description: "Celebrate 2026 with 20% off all beverages. Valid until January 31st. Don't miss out on your favorite coffee!",
        imageName: "https://i.postimg.cc/8z4DrKCv/Affogato-0.jpg",
        createdDate: "2 hours ago",
        isRead: false
    )
}
