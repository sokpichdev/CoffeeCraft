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
        }, onRefresh: {
            try? await announcementVM.fetchAnnouncements()
        })
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
    
    var threshold: CGFloat = 80
    var content: () -> Content
    var onRefresh: () async -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var isLocked = false
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init(
        threshold: CGFloat = 80,
        @ViewBuilder _ content: @escaping () -> Content,
        onRefresh: @escaping () async -> Void
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
                        .frame(height: isRefreshing ? 80 : min(offset, 80))
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
                .frame(height: 0),
                alignment: .top
            )
        }
        .scrollDisabled(isLocked) // Disable scroll when locked
        .coordinateSpace(name: "SCROLL")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            // Only process offset changes when not locked
            if !isRefreshing && !isLocked {
                if value > 0 {
                    offset = value
                    
                    // Trigger refresh when threshold is exceeded
                    if value > threshold {
                        triggerRefresh()
                    }
                } else if offset != 0 {
                    offset = 0
                }
            }
        }
    }
    
    private func triggerRefresh() {
        guard !isRefreshing && !isLocked else { return }
        
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred()
        
        isRefreshing = true
        isLocked = true
        
        // Snap offset to threshold position
        withAnimation(.easeOut(duration: 0.2)) {
            offset = threshold
        }
        
        Task {
            await onRefresh()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isRefreshing = false
                offset = 0
            }
            
            try await MinimumLoadingTime(0.4).waitIfNeeded()
            isLocked = false
        }
    }
}
