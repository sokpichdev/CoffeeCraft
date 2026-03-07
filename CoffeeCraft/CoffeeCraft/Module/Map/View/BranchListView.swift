//
//  BranchListView.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Richer cards: wait-time badge, icon color saturation, tighter typographic rhythm.
//

import SwiftUI

// MARK: - BranchListView

struct BranchListView: View {
    let branches: [Branch]
    let selectedBranch: Branch?
    let distanceLabel: (Branch) -> String
    let onSelect: (Branch) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(branches) { branch in
                        BranchCard(
                            branch: branch,
                            distance: distanceLabel(branch),
                            isSelected: selectedBranch?.id == branch.id
                        )
                        .id(branch.id)
                        .onTapGesture { onSelect(branch) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 14)
            }
            .onChange(of: selectedBranch?.id) { _, newId in
                guard let newId else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    proxy.scrollTo(newId, anchor: .center)
                }
            }
        }
    }
}

// MARK: - BranchCard

private struct BranchCard: View {
    let branch: Branch
    let distance: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────
            HStack(alignment: .top, spacing: 10) {
                // Icon tile
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(
                            isSelected
                                ? Color.accentPrimary
                                : Color.accentPrimary.opacity(0.1)
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color.accentPrimary)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? Color.accentPrimary : Color.textPrimary)
                        .lineLimit(1)

                    Text(branch.address)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 12)
                .opacity(0.5)

            // ── Status row ──────────────────────────────────────────
            HStack(spacing: 0) {
                // Open/closed
                HStack(spacing: 4) {
                    Circle()
                        .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                        .frame(width: 6, height: 6)
                    Text(branch.isOpen ? "Open" : "Closed")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                }

                if !distance.isEmpty {
                    Text("  ·  ")
                        .foregroundColor(Color.textMuted)
                        .font(.system(size: 11))

                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                            .foregroundColor(Color.textMuted)
                        Text(distance)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.textMuted)
                    }
                }

                Spacer(minLength: 0)

                // Wait time pill — shown when available
                if let wait = branch.estimatedWaitMinutes {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9, weight: .semibold))
                        Text(wait == 0 ? "No wait" : "~\(wait) min")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(wait == 0 ? Color.semanticSuccess : Color.accentPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                (wait == 0 ? Color.semanticSuccess : Color.accentPrimary)
                                    .opacity(0.1)
                            )
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // ── Amenity chips ────────────────────────────────────────
            if !branch.amenityIcons.isEmpty {
                HStack(spacing: 5) {
                    ForEach(branch.amenityIcons.prefix(3), id: \.label) { amenity in
                        HStack(spacing: 3) {
                            Image(systemName: amenity.icon)
                                .font(.system(size: 9, weight: .medium))
                            Text(amenity.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(Color.textSecondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.surfaceSub)
                        )
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            } else {
                Spacer().frame(height: 8)
            }
        }
        .frame(width: 232)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfacePrimary)
                .shadow(
                    color: isSelected
                        ? Color.accentPrimary.opacity(0.2)
                        : Color.black.opacity(0.07),
                    radius: isSelected ? 12 : 5,
                    x: 0, y: 3
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.accentPrimary.opacity(0.55) : Color.borderColor.opacity(0.6),
                    lineWidth: isSelected ? 1.5 : 0.5
                )
        }
        .scaleEffect(isSelected ? 1.025 : 1.0)
        .animation(.spring(response: 0.32, dampingFraction: 0.68), value: isSelected)
    }
}
