//
//  AnnouncementViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/11/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class AnnouncementViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    private let collection = "announcements"
    
    @Published var announcements: [Announcement] = []
    @Published var isLoading: Bool = false
    @Published var isAnnouncementsFetched: Bool = false
    @Published var isRefreshing: Bool = false
    // MARK: - Fetch All Announcements
    func fetchAnnouncements() async throws -> [Announcement] {
        isLoading = true
        isAnnouncementsFetched = false
        do {
            let snapshot = try await db.collection(collection)
                .order(by: "createdDate", descending: true)
                .getDocuments()
            
            let announcements = snapshot.documents.compactMap { document -> Announcement? in
                try? document.data(as: Announcement.self)
            }
            
            try await MinimumLoadingTime(0.5).waitIfNeeded()
            await MainActor.run {
                self.announcements = announcements
                self.isLoading = false
                self.isAnnouncementsFetched = true
            }
            
            return announcements
        } catch {
            await MainActor.run {
                AlertManager.shared.showError(message: error.localizedDescription)
                self.isLoading = false
                self.isAnnouncementsFetched = true
            }
            throw error
        }
    }
    
    // MARK: - Fetch Single Announcement
    func fetchAnnouncement(by id: String) async throws -> Announcement? {
        do {
            let document = try await db.collection(collection).document(id).getDocument()
            return try document.data(as: Announcement.self)
        } catch {
            throw error
        }
    }
    
    // MARK: - Create Announcement (Admin only)
    func createAnnouncement(_ announcement: Announcement) async throws {
        do {
            try db.collection(collection).document(announcement.id ?? "").setData(from: announcement)
        } catch {
            throw error
        }
    }
    
    // MARK: - Update Announcement (Admin only)
    func updateAnnouncement(_ announcement: Announcement) async throws {
        do {
            try db.collection(collection).document(announcement.id ?? "").setData(from: announcement, merge: true)
        } catch {
            throw error
        }
    }
    
    // MARK: - Delete Announcement (Admin only)
    func deleteAnnouncement(id: String) async throws {
        do {
            try await db.collection(collection).document(id).delete()
        } catch {
            throw error
        }
    }
    
    // MARK: - Real-time Listener
    func listenToAnnouncements(completion: @escaping ([Announcement]) -> Void) -> ListenerRegistration {
        return db.collection(collection)
            .order(by: "createdDate", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    AlertManager.shared.showError(title: "Error fetching announcements.", message: error?.localizedDescription ?? "Unknown Error")
                    return
                }
                
                let announcements = documents.compactMap { document -> Announcement? in
                    try? document.data(as: Announcement.self)
                }
                
                completion(announcements)
            }
    }
}
