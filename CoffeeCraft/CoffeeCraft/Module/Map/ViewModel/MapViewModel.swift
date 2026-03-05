//
//  MapViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 1: Basic Map Integration
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

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // update every 10 metres
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Actions

    /// Call this on MapView .onAppear to trigger the permission dialog.
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

    /// Re-center the camera on the user's current position.
    func recenterOnUser() {
        guard let location = userLocation else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1_000,
                    longitudinalMeters: 1_000
                )
            )
        }
    }

    // MARK: - Private Helpers

    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewModel: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isPermissionGranted {
            startUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latest = locations.last else { return }
        userLocation = latest

        // Only auto-center on the very first fix
        if cameraPosition == .automatic {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: latest.coordinate,
                    latitudinalMeters: 1_000,
                    longitudinalMeters: 1_000
                )
            )
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("[MapViewModel] Location error: \(error.localizedDescription)")
    }
}
