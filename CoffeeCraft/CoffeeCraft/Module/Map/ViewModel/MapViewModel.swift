//
//  MapViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 2: Branches on Map
//
//  Changes from Phase 1:
//  - Fix: replaced cameraPosition == .automatic with hasInitiallyLocated flag
//  - Add: branch list from MockBranchData (Firestore in Phase 6)
//  - Add: selectedBranch, distance helpers, focus(on:)
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

    /// Guards the initial auto-center so panning after the first fix is never hijacked.
    private var hasInitiallyLocated = false

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Actions

    /// Call on MapView .onAppear — triggers permission dialog or starts updates immediately.
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

    /// Load branches — MockBranchData for now, Firestore in Phase 6.
    func fetchBranches() {
        branches = MockBranchData.all
    }

    /// Branches sorted nearest-first from the user's current position.
    func sortedBranches() -> [Branch] {
        guard let userLocation else { return branches }
        return branches.sorted { distance(to: $0) < distance(to: $1) }
    }

    /// Distance in metres from userLocation to a branch.
    func distance(to branch: Branch) -> CLLocationDistance {
        guard let userLocation else { return .infinity }
        return userLocation.distance(from: CLLocation(
            latitude: branch.latitude,
            longitude: branch.longitude
        ))
    }

    /// Formatted distance label, e.g. "1.2 km" or "350 m".
    func distanceLabel(to branch: Branch) -> String {
        let metres = distance(to: branch)
        guard metres != .infinity else { return "" }
        return metres >= 1_000
            ? String(format: "%.1f km", metres / 1_000)
            : String(format: "%.0f m", metres)
    }

    /// Pan the camera to a branch with a comfortable zoom level.
    func focus(on branch: Branch) {
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: branch.coordinate,
                latitudinalMeters: 800,
                longitudinalMeters: 800
            ))
        }
    }

    /// Re-center camera on the user's live position.
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

        // ✅ Fix: MapCameraPosition is not Equatable.
        // The old `cameraPosition == .automatic` check never evaluated correctly.
        // A plain Bool flag is the correct guard for the initial auto-center.
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
