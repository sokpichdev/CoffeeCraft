//
//  MapView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 1: Basic Map Integration
//

import SwiftUI
import MapKit

// MARK: - MapView

struct MapView: View {

    @State private var viewModel = MapViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                // MARK: Map / Permission layer
                Group {
                    if viewModel.isPermissionDenied {
                        MapPermissionDeniedView()
                    } else {
                        mapLayer
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // MARK: Recenter button (only when location is available)
                if viewModel.isPermissionGranted {
                    recenterButton
                        .padding(.bottom, 32)
                        .padding(.trailing, 16)
                }
            }
            .customNavigationBar("Find a Branch", hideBackBtn: false)
            .onAppear {
                viewModel.requestLocationPermission()
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition) {
            // Phase 1: user dot only.
            // Branch annotations added in Phase 2.
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    // MARK: - Recenter Button

    private var recenterButton: some View {
        Button(action: viewModel.recenterOnUser) {
            ZStack {
                Circle()
                    .fill(.surfacePrimary)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.accentPrimary)
            }
        }
        .accessibilityLabel("Re-center map on my location")
    }
}
