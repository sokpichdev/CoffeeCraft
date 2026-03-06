//
//  BranchRepository.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.
//


//
//  BranchRepository.swift
//  CoffeeCraft
//
//  Map Module — Phase 4
//  Single source of truth for branch data.
//  Listens to Firestore branches/ collection in real time.
//  Falls back to MockBranchData when offline or on first load.
//

import FirebaseFirestore
import Foundation

// MARK: - BranchRepository

final class BranchRepository {

    static let shared = BranchRepository()
    private init() {}

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Listen

    /// Attaches a Firestore snapshot listener on branches/.
    /// Calls `onUpdate` immediately with the latest data on every change.
    /// Falls back to MockBranchData if the snapshot is empty or decoding fails.
    func listen(onUpdate: @escaping ([Branch]) -> Void) {
        listener = db.collection("branches")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    print("[BranchRepository] Listener error: \(error.localizedDescription) — using mock data")
                    onUpdate(MockBranchData.all)
                    return
                }

                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    print("[BranchRepository] Collection empty — using mock data")
                    onUpdate(MockBranchData.all)
                    return
                }

                let branches = docs.compactMap { doc -> Branch? in
                    do {
                        return try doc.data(as: Branch.self)
                    } catch {
                        print("[BranchRepository] Decode error for \(doc.documentID): \(error)")
                        return nil
                    }
                }

                print("[BranchRepository] ✅ Loaded \(branches.count) branches from Firestore")
                onUpdate(branches.isEmpty ? MockBranchData.all : branches)
            }
    }

    // MARK: - Stop

    func stopListening() {
        listener?.remove()
        listener = nil
        print("[BranchRepository] Listener removed")
    }
}