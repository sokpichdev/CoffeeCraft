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
        CustomRefreshScrollView(
            onRefresh: {
                try? await announcementVM.fetchAnnouncements()
            }
        ) {
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
            }
        }
        .customNavigationBar("Announcements") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomRefreshScrollView<Content: View>: View {
    
    var threshold: CGFloat = 60
    var onRefresh: () async -> Void
    var content: () -> Content
    
    @State private var offset: CGFloat = 0
    @State private var isRefreshing = false
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    init(
        threshold: CGFloat = 60,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.threshold = threshold
        self.onRefresh = onRefresh
        self.content = content
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if offset > 0 || isRefreshing {
                    CoffeeLoaderView(progress: isRefreshing ? nil : min(offset / threshold, 1), imageSize: 50)
                    .frame(height: isRefreshing ? 60 : min(offset, 60))
                }

                content()
            }
            .overlay(
                GeometryReader { geo in
                    let currentY = geo.frame(in: .named("SCROLL")).minY
                    Color.clear
                        .onAppear {}
                        .preference(key: ScrollOffsetPreferenceKey.self, value: currentY)
                }
                .frame(height: 0), // Keeps it from affecting layout
                alignment: .top
            )
        }
        .coordinateSpace(name: "SCROLL") // Ensure this is exactly the same string
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            if !isRefreshing {
                // 2. Detect only positive pull-down values
                if value > 0 {
                    offset = value
                } else if offset != 0 {
                    offset = 0
                }
                
                if value > threshold {
                    triggerRefresh()
                }
            }
        }
    }
    
    private func triggerRefresh() {
        // 1. Guard against double-triggering
        guard !isRefreshing else { return }
        
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred()
        
            isRefreshing = true
            offset = 0
        
        Task {
            await onRefresh()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isRefreshing = false
            }
        }
    }
}
