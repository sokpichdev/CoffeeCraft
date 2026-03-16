//
//  SavedLocationsView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - SavedLocationsView

struct SavedLocationsView: View {

    @State private var manager    = SavedLocationManager()
    @State private var showForm   = false
    @State private var editTarget: SavedLocation?
    @State private var deleteTarget: SavedLocation?

    @Environment(\.dismiss) private var dismiss

    private var userId: String { UserSession.shared.userId ?? "" }

    var body: some View {
        Group {
            if manager.isLoading {
                loadingState
            } else if manager.locations.isEmpty {
                emptyState
            } else {
                locationList
            }
        }
        .background(Color.bgSecondary)
        .customNavigationBar("My Addresses") {
            ToolBarButton.back { dismiss() }
            if manager.canAddMore {
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("plus")) {
                    editTarget = nil
                    showForm   = true
                }
            }
        }
        .sheet(isPresented: $showForm) {
            SavedLocationFormSheet(
                existing: editTarget,
                onSave: { handleSave($0) },
                onCancel: { showForm = false }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(26)
            .presentationBackground(Color.bgPrimary)
        }
        .alert("Remove Address", isPresented: .constant(deleteTarget != nil)) {
            Button("Remove", role: .destructive) { confirmDelete() }
            Button("Cancel", role: .cancel) { deleteTarget = nil }
        } message: {
            if let loc = deleteTarget {
                Text("\(loc.label) will be removed from your saved addresses.")
            }
        }
        .task { await manager.fetchLocations(for: userId) }
    }

    // MARK: - Location List

    private var locationList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(manager.locations) { location in
                    LocationRow(
                        location: location,
                        onSetDefault: { setDefault(location) },
                        onEdit: { startEdit(location) },
                        onDelete: { deleteTarget = location }
                    )

                    if location.id != manager.locations.last?.id {
                        Divider().padding(.leading, 66)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surfacePrimary)
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Limit caption
            if !manager.canAddMore {
                Text("Maximum 10 addresses reached")
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color.textMuted.opacity(0.5))
            Text("No saved addresses yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Color.textPrimary)
            Text("Save your home, work, or other spots\nfor faster checkout.")
                .font(.system(size: 14))
                .foregroundColor(Color.textMuted)
                .multilineTextAlignment(.center)
            Button {
                editTarget = nil
                showForm   = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Address")
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.accentPrimary)
                        .shadow(color: Color.accentPrimary.opacity(0.35), radius: 10, x: 0, y: 4)
                )
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 14) {
            Spacer()
            ProgressView().scaleEffect(1.2).tint(Color.accentPrimary)
            Text("Loading addresses…")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color.textMuted)
            Spacer()
        }
    }

    // MARK: - Actions

    private func startEdit(_ location: SavedLocation) {
        editTarget = location
        showForm   = true
    }

    private func setDefault(_ location: SavedLocation) {
        guard let id = location.id else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            try? await manager.setDefault(id: id, for: userId)
        }
    }

    private func handleSave(_ location: SavedLocation) {
        showForm = false
        Task {
            do {
                if location.id != nil {
                    try await manager.updateLocation(location, for: userId)
                } else {
                    try await manager.addLocation(location, for: userId)
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                AlertManager.shared.showError(
                    title: "Could Not Save",
                    message: error.localizedDescription
                )
            }
        }
    }

    private func confirmDelete() {
        guard let loc = deleteTarget, let id = loc.id else { return }
        deleteTarget = nil
        Task {
            try? await manager.deleteLocation(id: id, for: userId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - LocationRow

private struct LocationRow: View {

    let location: SavedLocation
    let onSetDefault: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Icon tile
            ZStack {
                Circle()
                    .fill(location.isDefault
                          ? Color.accentGold.opacity(0.15)
                          : Color(.tertiarySystemGroupedBackground))
                    .frame(width: 42, height: 42)
                Image(systemName: location.isDefault ? "house.fill" : "mappin.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(location.isDefault ? Color.accentGold : Color.textSecondary)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(location.label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    if location.isDefault {
                        Text("Default")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color.accentGold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentGold.opacity(0.15)))
                    }
                }
                Text(location.address)
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            // Context menu
            Menu {
                if !location.isDefault {
                    Button {
                        onSetDefault()
                    } label: {
                        Label("Set as Default", systemImage: "star.fill")
                    }
                }
                Button { onEdit() } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) { onDelete() } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textMuted)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
