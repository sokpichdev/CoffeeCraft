//
//  BranchListView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Created by Sok Pich
//  Map Module — Phase 2: Branches on Map
//

import SwiftUI

// MARK: - BranchListView

/// Horizontal scrollable strip sitting above the tab bar.
/// Tapping a card pans the map to that branch.
struct BranchListView: View {
    let branches: [Branch]
    let selectedBranch: Branch?
    let distanceLabel: (Branch) -> String
    let onSelect: (Branch) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
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
                .padding(.vertical, 12)
            }
            // Auto-scroll the strip when selectedBranch changes
            .onChange(of: selectedBranch?.id) { _, newId in
                guard let newId else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newId, anchor: .center)
                }
            }
        }
        .background(
            Color.bgPrimary
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}

// MARK: - BranchCard

private struct BranchCard: View {
    let branch: Branch
    let distance: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // ── Header row ──────────────────────────────────────────
            HStack(alignment: .top, spacing: 6) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentPrimary : Color.surfaceSub)
                        .frame(width: 38, height: 38)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .accentPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name)
                        .font(.custom("Nunito-Bold", size: 13))
                        .foregroundStyle(isSelected ? .accentPrimary : .textPrimary)
                        .lineLimit(1)

                    Text(branch.address)
                        .font(.custom("Nunito-Regular", size: 11))
                        .foregroundStyle(.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            // ── Status + distance row ────────────────────────────────
            HStack(spacing: 8) {
                // Open / Closed badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                        .frame(width: 6, height: 6)
                    Text(branch.isOpen ? "Open" : "Closed")
                        .font(.custom("Nunito-SemiBold", size: 11))
                        .foregroundStyle(branch.isOpen ? .semanticSuccess : .semanticError)
                }

                if !distance.isEmpty {
                    Text("·")
                        .foregroundStyle(.textMuted)
                        .font(.system(size: 11))

                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.textMuted)
                        Text(distance)
                            .font(.custom("Nunito-Regular", size: 11))
                            .foregroundStyle(.textMuted)
                    }
                }

                Spacer(minLength: 0)
            }

            // ── Amenity chips ────────────────────────────────────────
            if !branch.amenityIcons.isEmpty {
                HStack(spacing: 6) {
                    ForEach(branch.amenityIcons.prefix(3), id: \.label) { amenity in
                        HStack(spacing: 3) {
                            Image(systemName: amenity.icon)
                                .font(.system(size: 9, weight: .medium))
                            Text(amenity.label)
                                .font(.custom("Nunito-Regular", size: 10))
                        }
                        .foregroundStyle(.textSecondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.surfaceSub)
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 230)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.surfacePrimary)
                .shadow(
                    color: isSelected
                        ? Color.accentPrimary.opacity(0.18)
                        : Color.black.opacity(0.06),
                    radius: isSelected ? 8 : 4,
                    x: 0, y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isSelected ? Color.accentPrimary.opacity(0.5) : Color.border,
                    lineWidth: isSelected ? 1.5 : 0.8
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

//// MARK: - Preview
//
// #Preview {
//    ZStack(alignment: .bottom) {
//        Color.bgPrimary.ignoresSafeArea()
//        BranchListView(
//            branches: MockBranchData.all,
//            selectedBranch: MockBranchData.all[1],
//            distanceLabel: { _ in "1.2 km" },
//            onSelect: { _ in }
//        )
//    }
// }
