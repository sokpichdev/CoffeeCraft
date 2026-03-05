//
//  MapViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 3: Branch Selection + Routing
//
//  Changes from Phase 2:
//  - Add: isSheetPresented — controls BranchDetailSheet visibility
//  - Add: routePolyline — drawn on map when a branch is selected
//  - Add: etaLabel — travel time string from MKDirections
//  - Add: calculateRoute(to:) — async MKDirections fetch
//  - Add: selectBranch(_:) — single action that sets branch + fetches route + shows sheet
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - MapViewModel

@Observable
final class MapViewModel: NSObject {

    // MARK: - Map State

    var cameraPosition: MapCameraPosition = .automatic
    var userLocation: CLLocation?

    // MARK: - Branch State

    var branches: [Branch] = []
    var selectedBranch: Branch?

    // MARK: - Sheet + Route State

    var isSheetPresented = false
    var routePolyline: MKPolyline?
    var etaLabel: String = ""

    // MARK: - Permission State

    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var isPermissionDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var isPermissionGranted: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private var hasInitiallyLocated = false

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Location

    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        default:
            break
        }
    }

    func recenterOnUser() {
        guard let userLocation else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 1_000,
                longitudinalMeters: 1_000
            ))
        }
    }

    // MARK: - Branches

    func fetchBranches() {
        branches = MockBranchData.all
    }

    func sortedBranches() -> [Branch] {
        guard let userLocation else { return branches }
        return branches.sorted { distance(to: $0) < distance(to: $1) }
    }

    func distance(to branch: Branch) -> CLLocationDistance {
        guard let userLocation else { return .infinity }
        return userLocation.distance(from: CLLocation(
            latitude: branch.latitude,
            longitude: branch.longitude
        ))
    }

    func distanceLabel(to branch: Branch) -> String {
        let metres = distance(to: branch)
        guard metres != .infinity else { return "" }
        return metres >= 1_000
            ? String(format: "%.1f km", metres / 1_000)
            : String(format: "%.0f m", metres)
    }

    func focus(on branch: Branch) {
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: branch.coordinate,
                latitudinalMeters: 800,
                longitudinalMeters: 800
            ))
        }
    }

    // MARK: - Branch Selection (Phase 3)

    /// Single entry point for selecting a branch — sets state, fetches route, shows sheet.
    func selectBranch(_ branch: Branch) {
        withAnimation(.spring(response: 0.3)) {
            selectedBranch = branch
            isSheetPresented = true
        }
        focus(on: branch)

        Task {
            await calculateRoute(to: branch)
        }
    }

    /// Clears selection, hides sheet, removes route polyline.
    func deselectBranch() {
        withAnimation(.spring(response: 0.3)) {
            selectedBranch = nil
            isSheetPresented = false
            routePolyline = nil
            etaLabel = ""
        }
    }

    // MARK: - Route Calculation

    /// Calculates a driving route from the user's location to `branch` using MKDirections.
    /// Stores the polyline for map overlay and a human-readable ETA string.
    private func calculateRoute(to branch: Branch) async {
        guard let userLocation else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: userLocation.coordinate)
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: branch.coordinate)
        )
        request.transportType = .automobile

        do {
            let response = try await MKDirections(request: request).calculate()
            guard let route = response.routes.first else { return }

            await MainActor.run {
                routePolyline = route.polyline
                etaLabel = formatETA(route.expectedTravelTime)
            }
        } catch {
            print("[MapViewModel] Route error: \(error.localizedDescription)")
        }
    }

    private func formatETA(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        return minutes < 1 ? "< 1 min drive" : "~\(minutes) min drive"
    }

    // MARK: - Private

    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isPermissionGranted { startUpdatingLocation() }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latest = locations.last else { return }
        userLocation = latest

        guard !hasInitiallyLocated else { return }
        hasInitiallyLocated = true

        cameraPosition = .region(MKCoordinateRegion(
            center: latest.coordinate,
            latitudinalMeters: 1_000,
            longitudinalMeters: 1_000
        ))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[MapViewModel] Location error: \(error.localizedDescription)")
    }
}
