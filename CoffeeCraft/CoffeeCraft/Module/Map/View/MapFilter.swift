//
//  MapFilterChips.swift
//  CoffeeCraft
//
//  Map Module — Phase 6
//  Added: analytics call when a filter is toggled ON.
//  All visual behaviour unchanged from Phase 5.
//

import SwiftUI

// MARK: - MapFilter

enum MapFilter: String, CaseIterable, Identifiable {
    case openNow   = "Open Now"
    case wifi      = "WiFi"
    case parking   = "Parking"
    case drivethru = "Drive-Thru"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .openNow:   return "clock.fill"
        case .wifi:      return "wifi"
        case .parking:   return "parkingsign.circle"
        case .drivethru: return "car.fill"
        }
    }

    var amenityKey: String? {
        switch self {
        case .openNow:   return nil
        case .wifi:      return "wifi"
        case .parking:   return "parking"
        case .drivethru: return "drive-thru"
        }
    }

    func matches(_ branch: Branch) -> Bool {
        switch self {
        case .openNow: return branch.isOpen
        default:       return branch.amenities.contains(amenityKey ?? "")
        }
    }
}

// MARK: - MapFilterChips

struct MapFilterChips: View {

    @Binding var activeFilters: Set<MapFilter>
    var onFilterToggled: ((MapFilter) -> Void)?   // Phase 6 analytics hook

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MapFilter.allCases) { filter in
                    FilterChip(
                        filter: filter,
                        isActive: activeFilters.contains(filter)
                    ) {
                        toggleFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func toggleFilter(_ filter: MapFilter) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if activeFilters.contains(filter) {
                activeFilters.remove(filter)
            } else {
                activeFilters.insert(filter)
                onFilterToggled?(filter)     // fire analytics only when toggled ON
            }
        }
    }
}

// MARK: - FilterChip

private struct FilterChip: View {
    let filter: MapFilter
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(filter.rawValue)
                    .font(.custom("Nunito-SemiBold", size: 12))
            }
            .foregroundStyle(isActive ? .white : .accentPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isActive ? Color.accentPrimary : Color.surfacePrimary)
            .cornerRadius(20)
            .shadow(
                color: isActive
                    ? Color.accentPrimary.opacity(0.35)
                    : Color.black.opacity(0.06),
                radius: isActive ? 6 : 3,
                x: 0, y: 2
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isActive ? Color.clear : Color.border, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) filter, \(isActive ? "active" : "inactive")")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}
