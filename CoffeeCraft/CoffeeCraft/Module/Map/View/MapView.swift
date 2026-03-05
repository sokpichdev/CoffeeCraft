//
//  MapView.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 2: Branches on Map
//
//  Changes from Phase 1:
//  - Add: branch annotations with BranchAnnotationView
//  - Add: BranchListView strip pinned above tab bar
//  - Add: fetchBranches() on appear
//  - Tap annotation → selects branch + pans camera
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

                // MARK: Recenter button
                if viewModel.isPermissionGranted {
                    recenterButton
                        .padding(.bottom, 188) // sits above the branch strip
                        .padding(.trailing, 16)
                }

                // MARK: Branch list strip
                if !viewModel.branches.isEmpty {
                    VStack(spacing: 0) {
                        Spacer()
                        BranchListView(
                            branches: viewModel.sortedBranches(),
                            selectedBranch: viewModel.selectedBranch,
                            distanceLabel: { viewModel.distanceLabel(to: $0) },
                            onSelect: { branch in
                                viewModel.selectedBranch = branch
                                viewModel.focus(on: branch)
                            }
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .customNavigationBar("Find a Branch", hideBackBtn: false)
            .onAppear {
                viewModel.requestLocationPermission()
                viewModel.fetchBranches()
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition, selection: .constant(nil)) {
            // User location dot
            UserAnnotation()

            // Branch annotations
            ForEach(viewModel.branches) { branch in
                Annotation(branch.name, coordinate: branch.coordinate) {
                    BranchAnnotationView(
                        branch: branch,
                        isSelected: viewModel.selectedBranch?.id == branch.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedBranch = branch
                        }
                        viewModel.focus(on: branch)
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        // Tap map background → deselect branch
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedBranch = nil
            }
        }
    }

    // MARK: - Recenter Button

    private var recenterButton: some View {
        Button(action: viewModel.recenterOnUser) {
            ZStack {
                Circle()
                    .fill(Color.surfacePrimary)
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

//// MARK: - Preview
//
//#Preview {
//    MapView()
//}
