//
//  DeliveryDestinationPicker.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//
//  Map Module — Phase 4 (Delivery)
//  Shown after "Order from Here" is tapped.
//  Lets the user pick a saved address, use live GPS, or go add a new address.
//

import CoreLocation
import SwiftUI

// MARK: - DeliveryDestinationPicker

struct DeliveryDestinationPicker: View {

    let branch:          Branch
    let locationManager: SavedLocationManager
    let userCoordinate:  CLLocationCoordinate2D?
    let onConfirm:       (CLLocationCoordinate2D) -> Void
    let onCancel:        () -> Void

    @State private var selectedOption: DestinationOption = .currentLocation

    private enum DestinationOption: Hashable {
        case currentLocation
        case saved(SavedLocation)
    }

    // Resolved coordinate for the current selection
    private var resolvedCoordinate: CLLocationCoordinate2D? {
        switch selectedOption {
        case .currentLocation:
            return userCoordinate
        case .saved(let loc):
            return loc.coordinate
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.borderColor.opacity(0.8))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Title
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deliver to")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    Text("From \(branch.name)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.textMuted)
                }
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.textMuted)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.surfaceSub))
                }
                .buttonStyle(BounceButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Options list
            ScrollView {
                VStack(spacing: 0) {

                    // Current GPS location option
                    optionRow(
                        icon:       "location.fill",
                        iconColor:  Color.accentPrimary,
                        title:      "Current Location",
                        subtitle:   userCoordinate != nil
                                        ? "Use your GPS position now"
                                        : "Location unavailable",
                        isSelected: selectedOption == .currentLocation,
                        isDisabled: userCoordinate == nil
                    ) {
                        selectedOption = .currentLocation
                    }

                    if !locationManager.locations.isEmpty {
                        Divider().padding(.leading, 60)

                        // Saved locations
                        ForEach(locationManager.locations) { location in
                            optionRow(
                                icon:       location.isDefault ? "house.fill" : "mappin.circle.fill",
                                iconColor:  Color.accentGold,
                                title:      location.label,
                                subtitle:   location.address,
                                isSelected: selectedOption == .saved(location),
                                isDisabled: false,
                                badge:      location.isDefault ? "Default" : nil
                            ) {
                                selectedOption = .saved(location)
                            }

                            if location.id != locationManager.locations.last?.id {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.surfacePrimary)
                )
                .padding(.horizontal, 20)

                // Add address hint
                NavigationLink {
                    SavedLocationsView()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.accentPrimary)
                        Text("Manage saved addresses")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.accentPrimary)
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 4)
                }
            }
            .padding(.bottom, 8)

            // Confirm button
            Button {
                guard let coord = resolvedCoordinate else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onConfirm(coord)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bicycle")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Start Delivery")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(resolvedCoordinate != nil ? Color.accentPrimary : Color.textMuted)
                        .shadow(
                            color: resolvedCoordinate != nil ? Color.accentPrimary.opacity(0.4) : .clear,
                            radius: 12, x: 0, y: 5
                        )
                }
            }
            .buttonStyle(BounceButtonStyle())
            .disabled(resolvedCoordinate == nil)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.bgPrimary)
        .onAppear {
            // Pre-select the default saved location if one exists
            if let def = locationManager.defaultLocation {
                selectedOption = .saved(def)
            } else if userCoordinate != nil {
                selectedOption = .currentLocation
            }
        }
    }

    // MARK: - Option Row

    private func optionRow(
        icon:       String,
        iconColor:  Color,
        title:      String,
        subtitle:   String,
        isSelected: Bool,
        isDisabled: Bool,
        badge:      String? = nil,
        onTap:      @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isDisabled ? Color.textMuted : iconColor)
                        .symbolRenderingMode(.hierarchical)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isDisabled ? Color.textMuted : Color.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Color.accentGold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.accentGold.opacity(0.15)))
                        }
                    }
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.accentPrimary : Color.borderColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(BounceButtonStyle())
        .disabled(isDisabled)
    }
}
