//
//  InboxViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

//class InboxViewModel: ObservableObject {
//    @Published var displayedAnnouncements: [Announcement] = []
//    @Published var isLoading = false
//    @Published var selectedFilter: InboxFilter = .all
//    
//    private let itemsPerPage = 5
//    private var currentPage = 0
//    private var hasMoreData = true
//    
//    var filteredAnnouncements: [Announcement] {
//        switch selectedFilter {
//        case .all:
//            return displayedAnnouncements
//        case .unread:
//            return displayedAnnouncements.filter { !$0.isRead }
//        case .read:
//            return displayedAnnouncements.filter { $0.isRead }
//        }
//    }
//    
//    func loadInitial() {
//        guard displayedAnnouncements.isEmpty else { return }
//        loadMore()
//    }
//    
//    func loadMore() {
//        guard !isLoading && hasMoreData else { return }
//        
//        isLoading = true
//        
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            guard let self = self else { return }
//            
//            let startIndex = self.currentPage * self.itemsPerPage
//            let endIndex = min(startIndex + self.itemsPerPage, announcements.count)
//            
//            if startIndex < announcements.count {
//                let newItems = Array(announcements[startIndex..<endIndex])
//                self.displayedAnnouncements.append(contentsOf: newItems)
//                self.currentPage += 1
//                
//                // Check if we've loaded all items
//                if endIndex >= announcements.count {
//                    self.hasMoreData = false
//                }
//            } else {
//                self.hasMoreData = false
//            }
//            
//            self.isLoading = false
//        }
//    }
//    func markAsRead(id: String) {
//        guard let index = displayedAnnouncements.firstIndex(where: { $0.id == id }) else { return }
//        displayedAnnouncements[index].isRead = true
//    }
//    func markAllAsRead() {
//        for index in displayedAnnouncements.indices {
//            displayedAnnouncements[index].isRead = true
//        }
//    }
//
//}
