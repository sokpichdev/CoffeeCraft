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
    private let collection = Firebase.Announcements.collection
    
    @Published var announcements: [Announcement] = []
    @Published var isLoading: Bool = false
    @Published var isAnnouncementsFetched: Bool = false

    // MARK: - TTL Cache
    // Announcements are updated at most once or twice a day by admins.
    // Re-fetching on every Home tab switch wastes quota for data that
    // almost never changes. A 5-minute TTL eliminates ~95% of repeat reads.
    private var lastFetchDate: Date?
    private let cacheTTL: TimeInterval = 300 // 5 minutes

    /// Returns true when cached data is still fresh and a Firestore
    /// round-trip can be skipped entirely.
    private var isCacheValid: Bool {
        guard let last = lastFetchDate, !announcements.isEmpty else { return false }
        return Date().timeIntervalSince(last) < cacheTTL
    }

    /// Call this after any admin create / update / delete so the next
    /// fetchAnnouncements() always gets fresh data from Firestore.
    func invalidateCache() {
        lastFetchDate = nil
        AppLog.menu.debug("🗑️ AnnouncementViewModel — cache invalidated")
    }
    
    // MARK: - Fetch All Announcements
    func fetchAnnouncements() async {
        // Skip Firestore if cache is still fresh.
        if isCacheValid {
            AppLog.menu.debug("⚡ fetchAnnouncements — cache hit, skipping Firestore")
            isAnnouncementsFetched = true
            return
        }

        isLoading = true
        isAnnouncementsFetched = false
        
        AppLog.menu.debug("📡 Fetching all announcements...")
        
        do {
            let snapshot = try await db.collection(collection)
                .order(by: Firebase.Announcements.createdDate, descending: true)
                .getDocuments()
            
            let fetchedAnnouncements = snapshot.documents.compactMap { document -> Announcement? in
                try? document.data(as: Announcement.self)
            }
            
            AppLog.printList(fetchedAnnouncements, label: "Announcements")
            try await MinimumLoadingTime(0.5).waitIfNeeded()

            // Already @MainActor — no MainActor.run wrapper needed
            announcements = fetchedAnnouncements
            lastFetchDate = Date()
            isAnnouncementsFetched = true
            isLoading = false
        } catch {
            AppLog.menu.error("❌ Failed to fetch announcements: \(error.localizedDescription)")
            isAnnouncementsFetched = true
            isLoading = false
            AlertManager.shared.showError(message: error.localizedDescription)
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
            invalidateCache()
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
            invalidateCache()
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
            invalidateCache()
            AppLog.menu.debug("✅ Announcement deleted: \(id)")
        } catch {
            AppLog.menu.error("❌ Failed to delete announcement id \(id): \(error.localizedDescription)")
            throw error
        }
    }
}
