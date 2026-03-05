//
//  AnnouncementsListView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/18/25.
//
import SwiftUI

struct AnnouncementsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var announcementVM: AnnouncementViewModel
    var body: some View {
        CustomRefreshScrollView( {
            if announcementVM.isLoading {
                VStack {
                    ForEach(0..<5) { _ in
                        AnnouncementCardShimmerView()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                if announcementVM.announcements.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "megaphone")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No announcements yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Check back later for updates!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    VStack {
                        ForEach(announcementVM.announcements) { ann in
                            PushLink {
                                AnnouncementDetailView(announcement: ann)
                            } label: {
                                AnnouncementCardView(announcement: ann)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }, onRefresh: {
            _ = try? await announcementVM.fetchAnnouncements()
        })
        .background(Color.bgPrimary)
        .customNavigationBar("Announcements") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }
}
