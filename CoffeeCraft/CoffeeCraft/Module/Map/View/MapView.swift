//
//  MapView.swift
//  CoffeeCraft
//
//  Created by Sok Pich
//  Map Module — Phase 3: Branch Selection + Routing
//  Changes from Phase 2:
//  - Add: MapPolyline drawn when a branch is selected
//  - Add: BranchDetailSheet as a .sheet presentation
//  - Update: tap pin / strip card → selectBranch(_:) instead of direct assignment
//  - Add: "Order from here" writes to OrderEnvironment + switches tab
//

import SwiftUI
import MapKit

// MARK: - MapView

struct MapView: View {

    @State private var viewModel = MapViewModel()

    /// Shared environment — written here, read by the Order module.
    @EnvironmentObject private var orderEnv: OrderEnvironment

    /// Controls which tab is active — used by "Order from here" to jump to Menu/Orders.
    @Binding var selectedTab: Tab

    // MARK: - Init (default binding for preview / standalone use)

    init(selectedTab: Binding<Tab> = .constant(.home)) {
        self._selectedTab = selectedTab
    }

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
                        .padding(.bottom, 188)
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
                            onSelect: { viewModel.selectBranch($0) }
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
            // MARK: Branch detail sheet
            .sheet(isPresented: $viewModel.isSheetPresented) {
                viewModel.deselectBranch()
            } content: {
                if let branch = viewModel.selectedBranch {
                    BranchDetailSheet(
                        branch: branch,
                        distanceLabel: viewModel.distanceLabel(to: branch),
                        etaLabel: viewModel.etaLabel,
                        onOrderHere: {
                            orderEnv.select(branch: branch)
                            viewModel.isSheetPresented = false
                            // Switch to menu tab so user can browse + order
                            withAnimation(.easeInOut) { selectedTab = .menu }
                        },
                        onDismiss: {
                            viewModel.deselectBranch()
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden) // we draw our own handle
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.bgPrimary)
                }
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition, selection: .constant(nil)) {

            // User location dot
            UserAnnotation()

            // Route polyline (shown when a branch is selected)
            if let polyline = viewModel.routePolyline {
                MapPolyline(polyline)
                    .stroke(Color.accentPrimary, style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [8, 4]
                    ))
            }

            // Branch annotations
            ForEach(viewModel.branches) { branch in
                Annotation(branch.name, coordinate: branch.coordinate) {
                    BranchAnnotationView(
                        branch: branch,
                        isSelected: viewModel.selectedBranch?.id == branch.id
                    )
                    .onTapGesture {
                        viewModel.selectBranch(branch)
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        // Tap map background → deselect
        .onTapGesture {
            viewModel.deselectBranch()
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
//
//// MARK: - Preview
//
//#Preview {
//    MapView()
//        .environmentObject(OrderEnvironment.shared)
//}
