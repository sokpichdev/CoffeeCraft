//
//  MapView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 3/6/25.
//
import Foundation
import CoreLocation
import UIKit
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

    var body: some View {
        VStack {
            if let location = locationManager.userLocation {
                Text("Latitude: \(location.latitude)")
                Text("Longitude: \(location.longitude)")
                
                // Show on Map
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )))
                .frame(height: 300)
            } else {
                Text("Fetching location...")
            }

            Button("Request Location Again") {
                locationManager.requestPermissionAgain() // Check and ask for permission again
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
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
