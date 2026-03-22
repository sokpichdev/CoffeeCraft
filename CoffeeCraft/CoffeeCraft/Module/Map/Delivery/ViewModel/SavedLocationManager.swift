//
//  SavedLocationManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import FirebaseFirestore
import Foundation

// MARK: - SavedLocationManager

@Observable
final class SavedLocationManager {

    // MARK: - State

    var locations: [SavedLocation] = []
    var isLoading  = false
    var errorMessage: String?

    var canAddMore: Bool { locations.count < 10 }

    var defaultLocation: SavedLocation? {
        locations.first(where: \.isDefault)
    }

    // MARK: - Private

    private let db = Firestore.firestore()

    private func collection(for userId: String) -> CollectionReference {
        db.collection(Firebase.Users.collection).document(userId).collection(Firebase.Users.SavedLocations.collection)
    }

    // MARK: - Fetch

    func fetchLocations(for userId: String) async {
        await MainActor.run { isLoading = true }

        do {
            let snapshot = try await collection(for: userId)
                .order(by: Firebase.Users.SavedLocations.createdAt, descending: false)
                .getDocuments()

            var fetched = snapshot.documents.compactMap { doc -> SavedLocation? in
                try? doc.data(as: SavedLocation.self)
            }

            #if DEBUG
            // Inject a mock "Home" address for simulator testing.
            // Coordinates match the mock userLocation in MapViewModel:
            // Moscone Center, ~1.4 km from Union Square branch via city streets.
            // Apple Maps routes reliably between these two SF points.
            if fetched.isEmpty {
                fetched = [SavedLocation(
                    id: "debug_home",
                    label: "Home (Debug)",
                    address: "747 Howard St, Moscone Center, San Francisco, CA",
                    latitude: 37.7838,
                    longitude: -122.4014,
                    isDefault: true,
                    createdAt: Date()
                )]
            }
            #endif

            await MainActor.run {
                self.locations  = fetched
                self.isLoading  = false
                self.errorMessage = nil
            }
            AppLog.firestore.info("[SavedLocationManager] Fetched \(fetched.count) locations for \(userId)")
        } catch {
            await MainActor.run {
                self.isLoading    = false
                self.errorMessage = error.localizedDescription
            }
            AppLog.firestore.error("[SavedLocationManager] Fetch error: \(error.localizedDescription)")
        }
    }

    // MARK: - Add

    func addLocation(_ location: SavedLocation, for userId: String) async throws {
        guard canAddMore else {
            throw SavedLocationError.limitReached
        }

        var toSave       = location
        toSave.createdAt = Date()

        // If this is the first location, make it default automatically
        if locations.isEmpty { toSave.isDefault = true }

        let ref = collection(for: userId).document()
        try ref.setData(from: toSave)

        // If the new location should be default, clear others first
        if toSave.isDefault {
            try await clearOtherDefaults(except: ref.documentID, for: userId)
        }

        await fetchLocations(for: userId)
        AppLog.firestore.info("[SavedLocationManager] Added location '\(toSave.label)' for \(userId)")
    }

    // MARK: - Update

    func updateLocation(_ location: SavedLocation, for userId: String) async throws {
        guard let id = location.id else { return }

        try collection(for: userId).document(id).setData(from: location, merge: true)

        if location.isDefault {
            try await clearOtherDefaults(except: id, for: userId)
        }

        await fetchLocations(for: userId)
        AppLog.firestore.info("[SavedLocationManager] Updated location '\(location.label)'")
    }

    // MARK: - Delete

    func deleteLocation(id: String, for userId: String) async throws {
        try await collection(for: userId).document(id).delete()

        // If the deleted location was default and others exist, auto-promote the first one
        let wasDefault = locations.first(where: { $0.id == id })?.isDefault ?? false
        await fetchLocations(for: userId)

        if wasDefault, let first = locations.first, let firstId = first.id {
            try await setDefault(id: firstId, for: userId)
        }

        AppLog.firestore.info("[SavedLocationManager] Deleted location \(id)")
    }

    // MARK: - Set Default

    func setDefault(id: String, for userId: String) async throws {
        try await clearOtherDefaults(except: id, for: userId)
        try await collection(for: userId).document(id).updateData([Firebase.Users.SavedLocations.isDefault: true])
        await fetchLocations(for: userId)
        AppLog.firestore.info("[SavedLocationManager] Set default → \(id)")
    }

    // MARK: - Private Helpers

    private func clearOtherDefaults(except keepId: String, for userId: String) async throws {
        let currentDefaults = locations.filter { $0.isDefault && $0.id != keepId }
        for loc in currentDefaults {
            guard let id = loc.id else { continue }
            try await collection(for: userId).document(id).updateData([Firebase.Users.SavedLocations.isDefault: false])
        }
    }
}

// MARK: - SavedLocationError

enum SavedLocationError: LocalizedError {
    case limitReached

    var errorDescription: String? {
        switch self {
        case .limitReached:
            return "You can save up to 10 addresses. Remove one before adding another."
        }
    }
}
