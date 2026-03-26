//
//  DeliveryMapView.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//
//  Created by Sok Pich on 15/03/2026.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - DeliveryMapView

struct DeliveryMapView: View {

    // Passed in from MapView via OrderEnvironment — outlives this view.
    @ObservedObject var vm: DeliveryViewModel

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showConfetti: Bool = false
    /// Set to true when the user pinches/pans the map manually.
    /// Auto-zoom is paused until they tap the recenter button.
    @State private var userHasInteracted: Bool = false
    /// True only while fitCamera() is programmatically moving the camera,
    /// so onMapCameraChange can distinguish auto-zoom from user interaction.
    @State private var isAutoZooming: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Map layer ───────────────────────────────────────────
            mapLayer
                .ignoresSafeArea(edges: .bottom)

            // ── Loading overlay ─────────────────────────────────────
            if vm.isLoading {
                loadingOverlay
            }

            // ── Bottom status bar ───────────────────────────────────
            if !vm.isLoading, let session = vm.session {
                VStack(spacing: 0) {
                    // Timeout banner sits above the status bar
                    if vm.isTimeout {
                        timeoutBanner
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    DeliveryStatusBar(
                        status: session.status,
                        orderId: session.orderId,
                        estimatedArrival: vm.estimatedArrival
                    )
                    .padding(.horizontal, 0)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: vm.isTimeout)
            }

            // ── Recenter button — shown when user has panned/zoomed manually ──
            if userHasInteracted && !vm.isDelivered {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            userHasInteracted = false
                            if let coord = vm.riderCoordinate {
                                fitCamera(riderCoord: coord)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Follow rider")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.accentPrimary)
                                    .shadow(color: Color.accentPrimary.opacity(0.4), radius: 8, x: 0, y: 3)
                            )
                        }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.trailing, 16)
                        .padding(.bottom, 120)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: userHasInteracted)
            }

            // ── Delivered celebration ───────────────────────────────
            if vm.isDelivered {
                CoffeeAlertView(alertModel: AlertModel(type: .success,
                                                       title: "Delivered!",
                                                       message: "Enjoy your coffee ☕"),
                                isAutoDimiss: false) {
                    dismiss()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .customNavigationBar("Your Order") {
            ToolBarButton.back { dismiss() }
        }
        .onAppear {
            // VM is already running — just fit the camera to current session
            if let session = vm.session {
                let coords = [session.branchCoordinate, session.destinationCoordinate]
                cameraPosition = .region(regionFitting(coords: coords, padding: 1.4))
            }
        }
        .onDisappear {
            // Do NOT stop the VM — it lives in OrderEnvironment and must keep
            // running so the user can return to this screen from Order History.
        }
        // CLLocationCoordinate2D is not Equatable — observe tickCount instead.
        // tickCount increments every simulator tick, so this fires at the same frequency.
        .onChange(of: vm.tickCount) { _, _ in
            guard let coord = vm.riderCoordinate else { return }
            fitCamera(riderCoord: coord)
        }
        .onChange(of: vm.isDelivered) { _, delivered in
            if delivered {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showConfetti = true
                }
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $cameraPosition) {

            // User's destination pin
            if let session = vm.session {
                Annotation("Delivery Address", coordinate: session.destinationCoordinate) {
                    destinationPin
                }
                // Branch (origin) pin
                Annotation(session.branchId, coordinate: session.branchCoordinate) {
                    branchPin
                }
            }

            // Live rider pin
            if let coord = vm.riderCoordinate, let session = vm.session {
                Annotation("Rider", coordinate: coord) {
                    RiderAnnotationView(
                        status: session.status,
                        bearing: vm.riderBearing
                    )
                    // Smooth coordinate glide — MapKit moves the annotation,
                    // the bearing rotation is handled inside RiderAnnotationView.
                }
            }

            // Route polyline overlay
            if let poly = vm.routePolyline {
                MapPolyline(poly)
                    .stroke(
                        Color.accentPrimary.opacity(0.55),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [8, 4])
                    )
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .onMapCameraChange { _ in
            // Any camera change initiated by the user (pinch, pan, double-tap)
            // pauses auto-zoom so they can inspect the map freely.
            // We detect user interaction by checking if the change didn't come
            // from our own fitCamera() call — we set a flag before and after.
            if !isAutoZooming {
                userHasInteracted = true
            }
        }
    }

    // MARK: - Pins

    private var destinationPin: some View {
        ZStack {
            Circle()
                .fill(Color.accentPrimary.opacity(0.15))
                .frame(width: 52, height: 52)

            Circle()
                .fill(Color.accentPrimary)
                .frame(width: 34, height: 34)
                .shadow(color: Color.accentPrimary.opacity(0.4), radius: 8, x: 0, y: 3)

            Image(systemName: "house.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Your delivery address")
    }

    private var branchPin: some View {
        ZStack {
            Circle()
                .fill(Color.surfacePrimary)
                .frame(width: 36, height: 36)
                .overlay(Circle().strokeBorder(Color.borderColor, lineWidth: 1))
                .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 2)

            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.accentPrimary)
                .symbolRenderingMode(.hierarchical)
        }
        .accessibilityLabel("Branch — order origin")
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.bgPrimary.opacity(0.88)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(Color.accentPrimary)

                Text("Finding your rider…")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.textMuted)
            }
        }
    }

    // MARK: - Timeout Banner

    private var timeoutBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("We lost track of your rider")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Tap to retry live tracking")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button("Retry") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                vm.retry()
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(.white.opacity(0.22)))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.semanticWarning)
                .shadow(color: Color.semanticWarning.opacity(0.35), radius: 10, x: 0, y: 4)
        )
        .accessibilityLabel("Rider tracking lost. Double tap Retry to resume.")
    }

    // MARK: - Helpers

    // startDelivery() removed — VM lifecycle is owned by OrderEnvironment.
    // Camera is positioned in onAppear using vm.session.

    /// Smoothly re-fits the camera to keep the rider in frame.
    /// Only runs when the user hasn't manually interacted with the map.
    private func fitCamera(riderCoord: CLLocationCoordinate2D) {
        guard !userHasInteracted, let session = vm.session else { return }
        let coords = [riderCoord, session.destinationCoordinate]
        let region = regionFitting(coords: coords, padding: 1.6)
        isAutoZooming = true
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(region)
        }
        // Reset flag after animation so subsequent user interactions are detected
        Task {
            try? await Task.sleep(for: .seconds(0.7))
            isAutoZooming = false
        }
    }

    private func regionFitting(coords: [CLLocationCoordinate2D], padding: Double) -> MKCoordinateRegion {
        guard !coords.isEmpty else {
            let fallback = vm.session?.branchCoordinate
                ?? CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282)
            return MKCoordinateRegion(
                center: fallback,
                latitudinalMeters: 1000, longitudinalMeters: 1000
            )
        }
        let lats = coords.map(\.latitude)
        let lngs = coords.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLng = lngs.min(), let maxLng = lngs.max() else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282),
                latitudinalMeters: 1000, longitudinalMeters: 1000
            )
        }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        let latDelta = max((maxLat - minLat) * padding, 0.005)
        let lngDelta = max((maxLng - minLng) * padding, 0.005)
        return MKCoordinateRegion(center: center,
                                  span: MKCoordinateSpan(latitudeDelta: latDelta,
                                                         longitudeDelta: lngDelta))
    }
}
