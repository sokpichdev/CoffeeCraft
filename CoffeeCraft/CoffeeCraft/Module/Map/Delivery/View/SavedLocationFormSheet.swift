//
//  SavedLocationFormSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//
//  Map Module — Phase 4 (Saved Locations)
//  Add or edit a saved delivery address.
//  Uses MKLocalSearch for address autocomplete.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - SavedLocationFormSheet

struct SavedLocationFormSheet: View {

    // Pass nil to create a new location; pass an existing one to edit.
    var existing: SavedLocation?
    let onSave:   (SavedLocation) -> Void
    let onCancel: () -> Void

    // MARK: - Form State

    @State private var label:     String = ""
    @State private var address:   String = ""
    @State private var latitude:  Double = 0
    @State private var longitude: Double = 0
    @State private var isDefault: Bool   = false
    @State private var isSaving:  Bool   = false

    // MARK: - Address Search State

    @State private var searchQuery:    String = ""
    @State private var searchResults:  [MKLocalSearchCompletion] = []
    @State private var showSuggestions = false
    @State private var isSearching     = false

    private let completer = AddressCompleter()

    // MARK: - Validation

    private var isValid: Bool {
        !label.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        latitude != 0 && longitude != 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Label picker ────────────────────────────────
                    labelSection

                    // ── Address search ──────────────────────────────
                    addressSection

                    // ── Default toggle ──────────────────────────────
                    defaultToggleRow
                }
                .padding(20)
            }
            .background(Color.bgSecondary)
            .customNavigationBar(existing == nil ? "Add Address" : "Edit Address") {
                ToolBarButton.back { onCancel() }
                ToolBarButton(placement: .topBarTrailing, buttonType: .text("Save")) {
                    save()
                }
            }
        }
        .onAppear { prefill() }
        .onChange(of: searchQuery) { _, q in
            if q.count >= 2 {
                isSearching    = true
                showSuggestions = true
                completer.search(query: q) { results in
                    searchResults  = results
                    isSearching    = false
                }
            } else {
                searchResults   = []
                showSuggestions = false
            }
        }
    }

    // MARK: - Label Section

    private var labelSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Label", icon: "tag.fill")

            // Suggestion chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SavedLocation.suggestedLabels, id: \.self) { suggestion in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            label = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(label == suggestion ? .white : Color.accentPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background {
                                    Capsule()
                                        .fill(label == suggestion
                                              ? Color.accentPrimary
                                              : Color.accentPrimary.opacity(0.1))
                                }
                        }
                        .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.horizontal, 1)
            }

            // Custom label text field
            TextField("Or type a custom label…", text: $label)
                .font(.system(size: 15, design: .rounded))
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.surfacePrimary)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5))
                )
        }
    }

    // MARK: - Address Section

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Delivery Address", icon: "location.fill")

            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textMuted)

                TextField("Search for an address…", text: $searchQuery)
                    .font(.system(size: 15, design: .rounded))

                if isSearching {
                    ProgressView().scaleEffect(0.8)
                } else if !searchQuery.isEmpty {
                    Button {
                        searchQuery    = ""
                        searchResults  = []
                        showSuggestions = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.textMuted)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5))
            )

            // Autocomplete suggestions
            if showSuggestions && !searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchResults.prefix(5), id: \.title) { result in
                        Button {
                            selectSuggestion(result)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.accentPrimary)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.textPrimary)
                                        .lineLimit(1)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.textMuted)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(BounceButtonStyle())

                        if result.title != searchResults.prefix(5).last?.title {
                            Divider().padding(.leading, 50)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.surfacePrimary)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5))
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.3), value: searchResults.count)
            }

            // Resolved address confirmation pill
            if !address.isEmpty && latitude != 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.semanticSuccess)
                        .font(.system(size: 14))
                    Text(address)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.semanticSuccess.opacity(0.08))
                )
            }
        }
    }

    // MARK: - Default Toggle

    private var defaultToggleRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 36, height: 36)
                Image(systemName: "star.fill")
                    .font(.headline)
                    .foregroundColor(isDefault ? Color.accentGold : Color.textSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Set as default")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                Text("Pre-selected at checkout")
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
            }
            Spacer()
            Toggle("", isOn: $isDefault)
                .tint(Color.accentPrimary)
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.surfacePrimary)
        )
    }

    // MARK: - Section Header Helper

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.accentPrimary)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color.textMuted)
                .textCase(.uppercase)
                .tracking(0.5)
        }
    }

    // MARK: - Actions

    private func prefill() {
        guard let loc = existing else { return }
        label     = loc.label
        address   = loc.address
        latitude  = loc.latitude
        longitude = loc.longitude
        isDefault = loc.isDefault
        searchQuery = loc.address
    }

    private func selectSuggestion(_ completion: MKLocalSearchCompletion) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showSuggestions = false
        searchQuery     = completion.title

        // Geocode the completion to get lat/lng
        let request     = MKLocalSearch.Request(completion: completion)
        let search      = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let item = response?.mapItems.first else { return }
            let coord      = item.placemark.coordinate
            DispatchQueue.main.async {
                self.latitude  = coord.latitude
                self.longitude = coord.longitude
                self.address   = [
                    item.placemark.name,
                    item.placemark.thoroughfare,
                    item.placemark.locality,
                ].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

    private func save() {
        guard isValid else { return }

        isSaving = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        var location       = existing ?? SavedLocation(id: nil, label: "", address: "",
                                                       latitude: 0, longitude: 0,
                                                       isDefault: false, createdAt: Date())
        location.label     = label.trimmingCharacters(in: .whitespaces)
        location.address   = address.trimmingCharacters(in: .whitespaces)
        location.latitude  = latitude
        location.longitude = longitude
        location.isDefault = isDefault

        onSave(location)
    }
}

// MARK: - AddressCompleter (MKLocalSearchCompleter wrapper)

/// Thin wrapper around MKLocalSearchCompleter that exposes an async-friendly callback API.
private final class AddressCompleter: NSObject, MKLocalSearchCompleterDelegate {

    private let completer = MKLocalSearchCompleter()
    private var onResults: (([MKLocalSearchCompletion]) -> Void)?

    override init() {
        super.init()
        completer.delegate     = self
        completer.resultTypes  = .address
        completer.region       = MKCoordinateRegion(
            center:  CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282), // Phnom Penh
            span:    MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }

    func search(query: String, completion: @escaping ([MKLocalSearchCompletion]) -> Void) {
        onResults            = completion
        completer.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.onResults?(completer.results)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async { self.onResults?([]) }
    }
}
