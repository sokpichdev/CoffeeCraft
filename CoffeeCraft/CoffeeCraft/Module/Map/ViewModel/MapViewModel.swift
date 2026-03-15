//
//  MapViewModel.swift
//  CoffeeCraft
//
//  Map Module — Phase 6
//  Added: analytics events on selectBranch, filter toggle, search result.
//  All Phase 5 behaviour unchanged.
//

import CoreLocation
import MapKit
import SwiftUI

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

    // MARK: - Search & Filter

    var searchQuery: String = ""
    var activeFilters: Set<MapFilter> = []
    private var searchDebounceTask: Task<Void, Never>?

    func filteredBranches() -> [Branch] {
        let base = sortedBranches()

        let afterFilters = activeFilters.isEmpty
            ? base
            : base.filter { branch in activeFilters.allSatisfy { $0.matches(branch) } }

        let q = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return afterFilters }

        return afterFilters.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }
    }

    func updateSearchQuery(_ query: String) {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            await MainActor.run {
                self.searchQuery = query
                // Fire analytics if query has results
                let q = query.trimmingCharacters(in: .whitespaces)
                if !q.isEmpty {
                    MapAnalytics.mapSearched(
                        query: q,
                        resultCount: self.filteredBranches().count
                    )
                }
            }
        }
    }

    /// Called from MapFilterChips when a chip is toggled ON.
    func trackFilterApplied(_ filter: MapFilter) {
        MapAnalytics.filterApplied(filter)
    }

    var hasActiveSearchOrFilter: Bool {
        !searchQuery.isEmpty || !activeFilters.isEmpty
    }

    // MARK: - Offline State

    var isOffline = false

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

    override init() {
        super.init()
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter  = 10
        authorizationStatus             = locationManager.authorizationStatus

        #if DEBUG
        // Mock home location: Street 214, ~1.1 km south of branch_norodom via Norodom Blvd.
        // MKDirections routes reliably between these two points.
        // Remove or comment out when testing on a real device with GPS.
        let mockHome = CLLocation(latitude: 11.5528, longitude: 104.9237)
        userLocation = mockHome
        cameraPosition = .region(MKCoordinateRegion(
            center: mockHome.coordinate,
            latitudinalMeters: 1_500,
            longitudinalMeters: 1_500
        ))
        hasInitiallyLocated = true
        #endif
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
        isOffline = !NetworkMonitor.shared.isConnected
        BranchRepository.shared.listen { [weak self] updatedBranches in
            guard let self else { return }
            DispatchQueue.main.async {
                self.branches  = updatedBranches
                self.isOffline = !NetworkMonitor.shared.isConnected
            }
        }
    }

    func stopListening() {
        BranchRepository.shared.stopListening()
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

    func distanceKm(to branch: Branch) -> Double? {
        let m = distance(to: branch)
        guard m != .infinity else { return nil }
        return m / 1_000
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Analytics — Phase 6
        MapAnalytics.branchSelected(
            branchId: branch.id ?? "unknown",
            branchName: branch.name,
            distanceKm: distanceKm(to: branch)
        )

        withAnimation(.spring(response: 0.3)) {
            selectedBranch   = branch
            isSheetPresented = true
        }
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

    // MARK: - fitRoute

    func fitRoute(to branch: Branch) {
        guard let userLocation else {
            withAnimation(.easeInOut(duration: 0.4)) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: branch.coordinate,
                    latitudinalMeters: 800,
                    longitudinalMeters: 800
                ))
            }
            return
        }
        let userCoord   = userLocation.coordinate
        let branchCoord = branch.coordinate
        let minLat = min(userCoord.latitude, branchCoord.latitude)
        let maxLat = max(userCoord.latitude, branchCoord.latitude)
        let minLon = min(userCoord.longitude, branchCoord.longitude)
        let maxLon = max(userCoord.longitude, branchCoord.longitude)
        let latDelta = max((maxLat - minLat) * 1.6, 0.005)
        let lonDelta = max((maxLon - minLon) * 1.6, 0.005)
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (minLat + maxLat) / 2,
                    longitude: (minLon + maxLon) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: latDelta,
                    longitudeDelta: lonDelta
                )
            ))
        }
    }

    // MARK: - Apple Maps Handoff

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

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        AppLog.firestore.error("[MapViewModel] Location error: \(error.localizedDescription)")
    }
}
