//
//  BranchRepository.swift
//  CoffeeCraft
//
//  Map Module — Phase 6
//  Upgraded to use AppLog for structured, filterable console output.
//  Added: update(branchId:waitMinutes:) for staff to post wait times.
//  Listener logic unchanged from Phase 4.
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

    /// Attaches a real-time Firestore listener on branches/.
    /// Calls `onUpdate` immediately and on every subsequent change.
    /// Falls back to MockBranchData when the collection is empty or offline.
    func listen(onUpdate: @escaping ([Branch]) -> Void) {
        listener = db.collection("branches")
            .addSnapshotListener { snapshot, error in
                if let error {
                    AppLog.firestore.error(
                        "[BranchRepository] Listener error: \(error.localizedDescription) — using mock data"
                    )
                    onUpdate(MockBranchData.all)
                    return
                }

                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    AppLog.firestore.warning(
                        "[BranchRepository] Collection empty — using mock data"
                    )
                    onUpdate(MockBranchData.all)
                    return
                }

                let branches = docs.compactMap { doc -> Branch? in
                    do {
                        return try doc.data(as: Branch.self)
                    } catch {
                        AppLog.firestore.error(
                            "[BranchRepository] Decode error for \(doc.documentID): \(error)"
                        )
                        return nil
                    }
                }

                AppLog.firestore.info(
                    "[BranchRepository] ✅ Loaded \(branches.count) branches from Firestore"
                )
                onUpdate(branches.isEmpty ? MockBranchData.all : branches)
            }
    }

    // MARK: - Update Wait Time  (Phase 6 — admin only)

    /// Staff calls this to update the estimated wait time for a branch.
    /// Pass nil to remove the wait time display entirely.
    /// Firestore rules enforce that only managers can write this field.
    func update(branchId: String, waitMinutes: Int?) async throws {
        let data: [String: Any] = waitMinutes != nil
            ? ["estimatedWaitMinutes": waitMinutes!]
            : ["estimatedWaitMinutes": FieldValue.delete()]

        try await db.collection("branches")
            .document(branchId)
            .updateData(data)

        AppLog.firestore.info(
            "[BranchRepository] ✅ Wait time updated — branch: \(branchId), value: \(waitMinutes.map { "\($0) min" } ?? "cleared")"
        )
    }

    // MARK: - Stop

    func stopListening() {
        listener?.remove()
        listener = nil
        AppLog.firestore.debug("[BranchRepository] Listener removed")
    }
}
