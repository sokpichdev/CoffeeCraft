//
//  MapFilter.swift
//  CoffeeCraft
//
//  Map Module — Phase 6 (UI Enhanced)
//  Apple-style filter chips: glass material, spring animations, haptic-first.
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
        case .parking:   return "parkingsign.circle.fill"
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
    var onFilterToggled: ((MapFilter) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
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
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0)) {
            if activeFilters.contains(filter) {
                activeFilters.remove(filter)
            } else {
                activeFilters.insert(filter)
                onFilterToggled?(filter)
            }
        }
    }
}

// MARK: - FilterChip

private struct FilterChip: View {
    let filter: MapFilter
    let isActive: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.system(size: 11, weight: .semibold))
                    // Icon bounces slightly when toggling ON
                    .symbolEffect(.bounce, value: isActive)

                Text(filter.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(0.1)
            }
            .foregroundStyle(isActive ? .white : Color.accentPrimary)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background {
                if isActive {
                    Capsule()
                        .fill(Color.accentPrimary)
                        .shadow(color: Color.accentPrimary.opacity(0.4), radius: 8, x: 0, y: 3)
                } else {
                    Capsule()
                        .fill(.regularMaterial)
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                        }
                }
            }
        }
        .buttonStyle(BounceButtonStyle())
        .accessibilityLabel("\(filter.rawValue) filter, \(isActive ? "active" : "inactive")")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

// MARK: - BounceButtonStyle (shared press scale)

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
