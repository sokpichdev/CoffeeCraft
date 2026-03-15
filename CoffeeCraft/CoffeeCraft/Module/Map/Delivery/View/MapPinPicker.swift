//
//  MapPinPicker.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - MapPinPicker

/// Full-screen map where the user taps to drop a pin.
/// Reverse geocodes the pin to produce a human-readable address label.
struct MapPinPicker: View {

    let initialCoordinate: CLLocationCoordinate2D
    let onConfirm: (CLLocationCoordinate2D, String) -> Void
    let onCancel:  () -> Void

    @State private var cameraPosition: MapCameraPosition
    @State private var pinnedCoordinate: CLLocationCoordinate2D
    @State private var addressLabel = "Locating..."
    @State private var isGeocoding  = false

    init(
        initialCoordinate: CLLocationCoordinate2D,
        onConfirm: @escaping (CLLocationCoordinate2D, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.onConfirm = onConfirm
        self.onCancel = onCancel

        _pinnedCoordinate = State(initialValue: initialCoordinate)

        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: initialCoordinate,
                    latitudinalMeters: 1500,
                    longitudinalMeters: 1500
                )
            )
        )
    }

    var body: some View {
        ZStack {

            // MARK: Map

            MapReader { proxy in
                Map(position: $cameraPosition) {
                    Annotation("Delivery here", coordinate: pinnedCoordinate) {
                        pinView
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapUserLocationButton()
                }
                .ignoresSafeArea(edges: .bottom)

                // Tap to move pin
                .onTapGesture { point in

                    if let coord = proxy.convert(point, from: .local) {

                        UIImpactFeedbackGenerator(style: .light).impactOccurred()

                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pinnedCoordinate = coord

                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: coord,
                                    latitudinalMeters: 1000,
                                    longitudinalMeters: 1000
                                )
                            )
                        }

                        reverseGeocode(coord)
                    }
                }
            }

            // MARK: Overlay UI

            VStack {

                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 56)

                Spacer()

                bottomBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            reverseGeocode(initialCoordinate)
        }
    }

    // MARK: - Pin View

    private var pinView: some View {

        VStack(spacing: 0) {

            ZStack {

                Circle()
                    .fill(Color.accentPrimary.opacity(0.15))
                    .frame(width: 52, height: 52)

                Circle()
                    .fill(Color.accentPrimary)
                    .frame(width: 34, height: 34)
                    .shadow(
                        color: Color.accentPrimary.opacity(0.45),
                        radius: 8,
                        x: 0,
                        y: 3
                    )

                Image(systemName: "house.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            Rectangle()
                .fill(Color.accentPrimary)
                .frame(width: 3, height: 10)
                .cornerRadius(1.5)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {

        HStack {

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.regularMaterial))
                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(BounceButtonStyle())

            Spacer()

            Text("Tap to place pin")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(.ultraThinMaterial))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {

        VStack(spacing: 12) {

            // Address preview

            HStack(spacing: 12) {

                ZStack {

                    Circle()
                        .fill(Color.accentPrimary.opacity(0.12))
                        .frame(width: 36, height: 36)

                    if isGeocoding {

                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(Color.accentPrimary)

                    } else {

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.accentPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {

                    Text("Deliver to")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textMuted)
                        .textCase(.uppercase)
                        .tracking(0.4)

                    Text(addressLabel)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
            )

            // Confirm button

            Button {

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                onConfirm(pinnedCoordinate, addressLabel)

            } label: {

                HStack(spacing: 8) {

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))

                    Text("Confirm Location")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {

                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isGeocoding ? Color.textMuted : Color.accentPrimary)
                        .shadow(
                            color: isGeocoding ? .clear : Color.accentPrimary.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 5
                        )
                }
            }
            .buttonStyle(BounceButtonStyle())
            .disabled(isGeocoding)
        }
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {

        isGeocoding = true
        addressLabel = "Locating..."

        let location = CLLocation(
            latitude: coord.latitude,
            longitude: coord.longitude
        )

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in

            DispatchQueue.main.async {

                isGeocoding = false

                if let placemark = placemarks?.first {
                    addressLabel = placemark.formattedAddress
                } else {
                    addressLabel = "Pinned location"
                }
            }
        }
    }
}

// MARK: - Address Formatter
extension CLPlacemark {

    var formattedAddress: String {

        let parts = [
            subThoroughfare,
            thoroughfare,
            locality,
            administrativeArea
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }

        if parts.isEmpty {
            return name ?? "Pinned location"
        }

        return parts.joined(separator: ", ")
    }
}
