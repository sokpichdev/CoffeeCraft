//
//  MapView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 3/6/25.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var showPermissionAlert = false  // Controls alert visibility
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestLocationPermission() // Always ask on launch
    }
    
    /// **Requests permission on app launch or when denied**
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()  // Ask for permission
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()  // Start getting location
        case .denied, .restricted:
            showPermissionAlert = true  // Show alert when denied
        @unknown default:
            break
        }
    }
    
    /// **Requests permission when button is clicked**
    func requestPermissionAgain() {
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            showPermissionAlert = true // Show alert again if denied or restricted
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// **Opens Settings if the user denied permission**
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    /// **Handles location updates**
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    /// **Handles permission changes**
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            showPermissionAlert = true  // Show alert when denied
        }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var searchQuery = ""
    @State private var places: [Place] = []
    @State private var selectedPlace: Place? = nil

    // Custom structure that wraps MKMapItem and conforms to Identifiable
    struct Place: Identifiable {
        var id: String {
            return mapItem.name ?? UUID().uuidString
        }
        let mapItem: MKMapItem
    }

    private func searchPlaces(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region  // Restrict search to the current region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching places: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            places = response.mapItems.map { Place(mapItem: $0) }
        }
    }

    var body: some View {
        VStack {
            if let location = locationManager.userLocation {
                Text("Latitude: \(location.latitude)")
                Text("Longitude: \(location.longitude)")

                // Show on Map with dynamically updated region
                Map(coordinateRegion: $region, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.mapItem.placemark.coordinate) {
                        VStack {
                            Image(systemName: "mappin")
                                .foregroundColor(.red)
                                .font(.title)
                            
                            // Tap gesture to show info
                            Button(action: {
                                // Safe state update
                                withAnimation {
                                    selectedPlace = place
                                }
                            }) {
                                Text("Tap for Info")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onAppear {
                    // Set region to the user's location when it's available
                    if let location = locationManager.userLocation {
                        region.center = location
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Full-screen map
            } else {
                Text("Fetching location...")
            }

            // Search bar
            TextField("Search for places", text: $searchQuery, onCommit: {
                searchPlaces(query: searchQuery)  // Perform search when the user presses return
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onChange(of: searchQuery) { newQuery in
                if newQuery.isEmpty {
                    places.removeAll()  // Clear places when search query is empty
                }
            }

            Button("Request Location Again") {
                locationManager.requestPermissionAgain() // Check and ask for permission again
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            // Display selected place info when tapped
            if let selectedPlace = selectedPlace {
                VStack {
                    Text("Place Info")
                        .font(.headline)
                    Text("Name: \(selectedPlace.mapItem.name ?? "Unknown")")
                    Text("Address: \(selectedPlace.mapItem.placemark.title ?? "Unknown")")
                    Button("Close") {
                        self.selectedPlace = nil  // Close info view
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top, 10)
                .transition(.move(edge: .bottom))
                .animation(.spring())
            }
        }
        .alert("Location Permission Needed", isPresented: $locationManager.showPermissionAlert) {
            Button("Allow") {
                locationManager.requestLocationPermission()  // Allow permission request
            }
            Button("Go to Settings") {
                locationManager.openAppSettings()  // Go to settings to change permissions
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This app needs your location to display it on the map.")
        }
        .padding()
    }
}

