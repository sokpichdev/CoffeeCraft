//
//  DeliveryDestinationPicker.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//
//  Fulfillment Module
//  Shown by FulfillmentPickerSheet when the user selects Delivery.
//
//  Three ways to set a delivery address:
//    1. Current Location  — one-tap GPS
//    2. Saved addresses   — addresses stored in the user's profile
//    3. Search            — MKLocalSearch autocomplete
//    4. Pick on map       — drop a pin anywhere, reverse geocode for label
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - DeliveryDestinationPicker

struct DeliveryDestinationPicker: View {

    let branch:          Branch
    let locationManager: SavedLocationManager
    let userCoordinate:  CLLocationCoordinate2D?
    let onConfirm:       (CLLocationCoordinate2D, String) -> Void
    let onCancel:        () -> Void

    @State private var selectedOption: DestinationOption = .currentLocation
    @State private var searchText    = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching   = false
    @State private var showMapPicker = false

    private enum DestinationOption: Hashable, Equatable {

        case currentLocation
        case saved(SavedLocation)
        case searched(MKMapItem)
        case pinned(CLLocationCoordinate2D, String) // coord + reverse-geocoded label

        // MARK: Equatable
        // MKMapItem and CLLocationCoordinate2D don't synthesize Equatable automatically.

        static func == (lhs: DestinationOption, rhs: DestinationOption) -> Bool {
            switch (lhs, rhs) {
            case (.currentLocation, .currentLocation):
                return true
            case (.saved(let a), .saved(let b)):
                return a == b
            case (.searched(let a), .searched(let b)):
                // MKMapItem equality: same placemark name + coordinate
                return a.placemark.coordinate.latitude  == b.placemark.coordinate.latitude
                    && a.placemark.coordinate.longitude == b.placemark.coordinate.longitude
                    && a.name == b.name
            case (.pinned(let coordA, let labelA), .pinned(let coordB, let labelB)):
                return coordA.latitude  == coordB.latitude
                    && coordA.longitude == coordB.longitude
                    && labelA           == labelB
            default:
                return false
            }
        }

        // MARK: Hashable

        func hash(into hasher: inout Hasher) {
            switch self {
            case .currentLocation:
                hasher.combine(0)
            case .saved(let loc):
                hasher.combine(1)
                hasher.combine(loc.id)
            case .searched(let item):
                hasher.combine(2)
                hasher.combine(item.placemark.coordinate.latitude)
                hasher.combine(item.placemark.coordinate.longitude)
                hasher.combine(item.name)
            case .pinned(let coord, let label):
                hasher.combine(3)
                hasher.combine(coord.latitude)
                hasher.combine(coord.longitude)
                hasher.combine(label)
            }
        }
    }

    private var resolvedCoordinate: CLLocationCoordinate2D? {
        switch selectedOption {
        case .currentLocation:           return userCoordinate
        case .saved(let loc):            return loc.coordinate
        case .searched(let item):        return item.placemark.coordinate
        case .pinned(let coord, _):      return coord
        }
    }

    private var resolvedAddressLabel: String {
        switch selectedOption {
        case .currentLocation:           return "Current Location"
        case .saved(let loc):            return loc.address
        case .searched(let item):        return item.placemark.formattedAddress
        case .pinned(_, let label):      return label
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            header
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Search bar
            searchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Results / options list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if searchText.isEmpty {
                        defaultOptions
                    } else {
                        searchResultRows
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.surfacePrimary)
                )
                .padding(.horizontal, 20)

                // Pick on map row (always visible)
                pickOnMapButton
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                // Manage saved
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
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                }
            }
            .padding(.bottom, 8)

            confirmButton
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
        .background(Color.bgPrimary)
        .sheet(isPresented: $showMapPicker) {
            MapPinPicker(
                initialCoordinate: userCoordinate
                    ?? resolvedCoordinate
                    ?? branch.coordinate,
                onConfirm: { coord, label in
                    selectedOption   = .pinned(coord, label)
                    showMapPicker    = false
                },
                onCancel: { showMapPicker = false }
            )
        }
        .onAppear {
            if let def = locationManager.defaultLocation {
                selectedOption = .saved(def)
            } else if userCoordinate != nil {
                selectedOption = .currentLocation
            }
        }
        .onChange(of: searchText) { _, query in
            runSearch(query)
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color.borderColor.opacity(0.8))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Header

    private var header: some View {
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
    }
}

extension DeliveryDestinationPicker {
    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(searchText.isEmpty ? Color.textMuted : Color.accentPrimary)

            TextField("Search for an address...", text: $searchText)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText    = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color.textMuted)
                }
            }

            if isSearching {
                ProgressView()
                    .scaleEffect(0.75)
                    .tint(Color.accentPrimary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            searchText.isEmpty
                                ? Color.borderColor.opacity(0.5)
                                : Color.accentPrimary.opacity(0.5),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - Default Options (no search)

    @ViewBuilder
    private var defaultOptions: some View {
            // Current GPS
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

            // Saved addresses
            if !locationManager.locations.isEmpty {
                Divider().padding(.leading, 60)

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

            // Show currently pinned result if one was picked from map
            if case .pinned(_, let label) = selectedOption {
                Divider().padding(.leading, 60)
                optionRow(
                    icon:       "mappin.circle.fill",
                    iconColor:  Color.semanticSuccess,
                    title:      "Pinned location",
                    subtitle:   label,
                    isSelected: true,
                    isDisabled: false
                ) {}
            }
    }

    // MARK: - Search Result Rows

    @ViewBuilder
    private var searchResultRows: some View {
        if searchResults.isEmpty && !isSearching {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(Color.textMuted)
                Text("No results for \"\(searchText)\"")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color.textMuted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ForEach(searchResults, id: \.self) { item in
                optionRow(
                    icon:       "mappin.circle.fill",
                    iconColor:  Color.accentPrimary,
                    title:      item.placemark.name ?? item.placemark.formattedAddress,
                    subtitle:   item.placemark.formattedAddress,
                    isSelected: selectedOption == .searched(item),
                    isDisabled: false
                ) {
                    selectedOption = .searched(item)
                    searchText     = ""
                    searchResults  = []
                }

                if item != searchResults.last {
                    Divider().padding(.leading, 60)
                }
            }
        }
    }

    // MARK: - Pick on Map Button

    private var pickOnMapButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showMapPicker = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentPrimary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "map.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.accentPrimary)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Pick on map")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    Text("Drop a pin anywhere")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.textMuted.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.accentPrimary.opacity(0.25), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button {
            guard let coord = resolvedCoordinate else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onConfirm(coord, resolvedAddressLabel)
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
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isDisabled ? Color.textMuted : iconColor)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isDisabled ? Color.textMuted : Color.textPrimary)
                            .lineLimit(1)
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

    // MARK: - Search

    private func runSearch(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            isSearching   = false
            return
        }

        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        // Bias results toward the branch location so nearby addresses rank higher
        request.region = MKCoordinateRegion(
            center: branch.coordinate,
            latitudinalMeters: 10_000,
            longitudinalMeters: 10_000
        )

        Task {
            let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
            await MainActor.run {
                searchResults = Array(items.prefix(5))
                isSearching   = false
            }
        }
    }
}
