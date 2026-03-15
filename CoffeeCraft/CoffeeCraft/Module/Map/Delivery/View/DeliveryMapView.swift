//
//  DeliveryMapView.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//
//  Full-screen delivery tracking screen shown after an order is placed.
//  Composes: live Map, RiderAnnotationView, route polyline, DeliveryStatusBar,
//  delivered celebration overlay, and timeout / loading edge states.
//
//  Usage
//  ──────────────────────────────────────────────────────────────────────────
//  DeliveryMapView(vm: DeliveryViewModel)
//
//  The VM is owned by OrderEnvironment so it survives navigation back/forward.
//  This view only drives the camera and confetti — it never starts or stops the VM.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - DeliveryMapView

struct DeliveryMapView: View {

    // Passed in from MapView via OrderEnvironment — outlives this view.
    @ObservedObject var vm: DeliveryViewModel

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showConfetti  = false

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
                        status:           session.status,
                        orderId:          session.orderId,
                        estimatedArrival: vm.estimatedArrival
                    )
                    .padding(.horizontal, 0)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: vm.isTimeout)
            }

            // ── Delivered celebration ───────────────────────────────
            if vm.isDelivered {
                deliveredOverlay
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
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
                        status:  session.status,
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

    // MARK: - Delivered Overlay

    private var deliveredOverlay: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.semanticSuccess.opacity(0.15))
                    .frame(width: 90, height: 90)

                Circle()
                    .fill(Color.semanticSuccess)
                    .frame(width: 68, height: 68)
                    .shadow(color: Color.semanticSuccess.opacity(0.4), radius: 14, x: 0, y: 5)

                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Delivered!")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)

            Text("Enjoy your coffee ☕")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.textMuted)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 50)
                    .background(
                        Capsule()
                            .fill(Color.accentPrimary)
                            .shadow(color: Color.accentPrimary.opacity(0.4), radius: 10, x: 0, y: 4)
                    )
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.top, 4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.bgPrimary)
                .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your order has been delivered. Tap Done to close.")
    }

    // MARK: - Helpers

    // startDelivery() removed — VM lifecycle is owned by OrderEnvironment.
    // Camera is positioned in onAppear using vm.session.

    /// Smoothly re-fits the camera to keep the rider in frame.
    private func fitCamera(riderCoord: CLLocationCoordinate2D) {
        guard let session = vm.session else { return }
        let coords = [riderCoord, session.destinationCoordinate]
        let region = regionFitting(coords: coords, padding: 1.6)
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(region)
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
        let minLat = lats.min()!, maxLat = lats.max()!
        let minLng = lngs.min()!, maxLng = lngs.max()!
        let center = CLLocationCoordinate2D(
            latitude:  (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        let latDelta = max((maxLat - minLat) * padding, 0.005)
        let lngDelta = max((maxLng - minLng) * padding, 0.005)
        return MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta))
    }
}
