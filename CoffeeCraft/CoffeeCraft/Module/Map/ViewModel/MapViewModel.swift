//
//  MapViewModel.swift
//  CoffeeCraft
//
//  Map Module — Simplified
//  Responsibilities: location, branch list, branch selection, sheet presentation.
//  Routing, directions, and delivery simulation removed — Phase 5+.
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
    var isSheetPresented = false

    // MARK: - Permission State

    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var isPermissionDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var isPermissionGranted: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    // MARK: - Private

    private let locationManager     = CLLocationManager()
    private var hasInitiallyLocated = false

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter  = 10
        authorizationStatus             = locationManager.authorizationStatus
    }

    // MARK: - Location

    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
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
        // TODO Phase 6: replace with Firestore listener
        branches = MockBranchData.all
    }

    func sortedBranches() -> [Branch] {
        guard let userLocation else { return branches }
        return branches.sorted { distance(to: $0) < distance(to: $1) }
    }

    func distance(to branch: Branch) -> CLLocationDistance {
        guard let userLocation else { return .infinity }
        return userLocation.distance(from: CLLocation(
            latitude:  branch.latitude,
            longitude: branch.longitude
        ))
    }

    func distanceLabel(to branch: Branch) -> String {
        let m = distance(to: branch)
        guard m != .infinity else { return "" }
        return m >= 1_000
            ? String(format: "%.1f km", m / 1_000)
            : String(format: "%.0f m", m)
    }

    // MARK: - Selection

    func selectBranch(_ branch: Branch) {
        withAnimation(.spring(response: 0.3)) {
            selectedBranch   = branch
            isSheetPresented = true
        }
        // Pan map to branch
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: branch.coordinate,
                latitudinalMeters: 800,
                longitudinalMeters: 800
            ))
        }
    }

    func deselectBranch() {
        withAnimation(.spring(response: 0.3)) {
            selectedBranch   = nil
            isSheetPresented = false
        }
    }

    // MARK: - Open in Apple Maps

    func openInAppleMaps(branch: Branch) {
        let placemark = MKPlacemark(coordinate: branch.coordinate)
        let item      = MKMapItem(placemark: placemark)
        item.name     = branch.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isPermissionGranted { manager.startUpdatingLocation() }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        userLocation = latest
        guard !hasInitiallyLocated else { return }
        hasInitiallyLocated = true
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: latest.coordinate,
                latitudinalMeters: 1_000,
                longitudinalMeters: 1_000
            ))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[MapViewModel] Location error: \(error.localizedDescription)")
    }
}
