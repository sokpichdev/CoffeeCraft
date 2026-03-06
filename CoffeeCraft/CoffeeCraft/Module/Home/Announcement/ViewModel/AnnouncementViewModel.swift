import FirebaseFirestore
//
//  AnnouncementViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/11/26.
//
import Foundation
import OSLog

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
        
        AppLog.menu.debug("📡 Fetching all announcements...")
        
        do {
            let snapshot = try await db.collection(collection)
                .order(by: "createdDate", descending: true)
                .getDocuments()
            
            let fetchedAnnouncements = snapshot.documents.compactMap { document -> Announcement? in
                try? document.data(as: Announcement.self)
            }
            
            AppLog.printList(fetchedAnnouncements, label: "Announcements")
            
            try await MinimumLoadingTime(0.5).waitIfNeeded()
            
            await MainActor.run {
                self.announcements = fetchedAnnouncements
                self.isAnnouncementsFetched = true
                self.isLoading = false
            }
            
            return fetchedAnnouncements
        } catch {
            AppLog.menu.error("❌ Failed to fetch announcements: \(error.localizedDescription)")
            await MainActor.run {
                self.isAnnouncementsFetched = true
                self.isLoading = false
                AlertManager.shared.showError(message: error.localizedDescription)
            }
            throw error
        }
    }
    
    // MARK: - Fetch Single Announcement
    func fetchAnnouncement(by id: String) async throws -> Announcement? {
        AppLog.menu.debug("📡 Fetching announcement by id: \(id)")
        do {
            let document = try await db.collection(collection).document(id).getDocument()
            let announcement = try document.data(as: Announcement.self)
            AppLog.menu.debug("✅ Fetched announcement: \(String(describing: announcement))")
            return announcement
        } catch {
            AppLog.menu.error("❌ Failed to fetch announcement id \(id): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Create Announcement (Admin only)
    func createAnnouncement(_ announcement: Announcement) async throws {
        AppLog.menu.debug("📡 Creating announcement: \(announcement.id ?? "no id")")
        do {
            try db.collection(collection).document(announcement.id ?? "").setData(from: announcement)
            AppLog.menu.debug("✅ Announcement created successfully")
        } catch {
            AppLog.menu.error("❌ Failed to create announcement: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Update Announcement (Admin only)
    func updateAnnouncement(_ announcement: Announcement) async throws {
        AppLog.menu.debug("📡 Updating announcement: \(announcement.id ?? "no id")")
        do {
            try db.collection(collection).document(announcement.id ?? "").setData(from: announcement, merge: true)
            AppLog.menu.debug("✅ Announcement updated successfully")
        } catch {
            AppLog.menu.error("❌ Failed to update announcement: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete Announcement (Admin only)
    func deleteAnnouncement(id: String) async throws {
        AppLog.menu.debug("📡 Deleting announcement: \(id)")
        do {
            try await db.collection(collection).document(id).delete()
            AppLog.menu.debug("✅ Announcement deleted: \(id)")
        } catch {
            AppLog.menu.error("❌ Failed to delete announcement id \(id): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Real-time Listener
    func listenToAnnouncements(completion: @escaping ([Announcement]) -> Void) -> ListenerRegistration {
        AppLog.menu.debug("👂 Starting real-time listener for announcements...")
        return db.collection(collection)
            .order(by: "createdDate", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    AppLog.menu.error("❌ Listener error: \(error.localizedDescription)")
                    AlertManager.shared.showError(title: "Error fetching announcements.", message: error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    AppLog.menu.warning("⚠️ Snapshot is nil or has no documents")
                    AlertManager.shared.showError(title: "Error fetching announcements.", message: "Unknown Error")
                    return
                }
                
                let announcements = documents.compactMap { document -> Announcement? in
                    try? document.data(as: Announcement.self)
                }
                
                AppLog.menu.debug("✅ Listener received \(documents.count) announcement(s), decoded \(announcements.count)")
                completion(announcements)
            }
    }
}
