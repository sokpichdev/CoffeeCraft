//
//  MapView.swift
//  CoffeeCraft
//
//  Map Module — Phase 4
//  Added: offline banner when isOffline == true.
//  Added: stopListening() on disappear.
//  Everything else unchanged from Phase 3.
//

import MapKit
import SwiftUI

struct MapView: View {

    @State private var viewModel  = MapViewModel()
    @State private var localSearch = ""
    @EnvironmentObject private var orderEnv: OrderEnvironment

    var body: some View {
//        CustomNavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: Map / Permission
                Group {
                    if viewModel.isPermissionDenied {
                        MapPermissionDeniedView()
                    } else {
                        mapLayer
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // MARK: Offline banner
                if viewModel.isOffline {
                    VStack {
                        offlineBanner
                        Spacer()
                    }
                    .ignoresSafeArea(edges: .top)
                }

                // MARK: Recenter button
                if viewModel.isPermissionGranted {
                    HStack {
                        Spacer()
                        recenterButton
                            .padding(.bottom, viewModel.filteredBranches().isEmpty ? 32 : 244)
                            .padding(.trailing, 16)
                    }
                }

                // MARK: Bottom panel — search + filters + branch strip
                VStack(spacing: 0) {
                    Spacer()
                    bottomPanel
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            .onAppear {
                viewModel.requestLocationPermission()
                viewModel.fetchBranches()
            }
            .onDisappear {
                viewModel.stopListening()
            }

            // MARK: Branch detail sheet
            .sheet(isPresented: $viewModel.isSheetPresented,
                   onDismiss: { viewModel.deselectBranch() }) {
                if let branch = viewModel.selectedBranch {
                    BranchDetailSheet(
                        branch: branch,
                        viewModel: viewModel,
                        onOrderHere: {
                            // Write branch to shared env; MenuBranchSelectionSheet's
                            // onChange will auto-dismiss and MenuView will show products.
                            orderEnv.select(branch: branch)
                            viewModel.isSheetPresented = false
                        },
                        onDismiss: { viewModel.deselectBranch() }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.bgPrimary)
                }
            }
//        }
        .customNavigationBar("Find a Branch", hideBackBtn: false)
    }

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            // Search bar + filter chips
            VStack(spacing: 8) {
                MapSearchBar(text: $localSearch) {
                    viewModel.searchQuery = ""
                }
                .padding(.horizontal, 16)
                .onChange(of: localSearch) { _, new in
                    viewModel.updateSearchQuery(new)
                }

                MapFilterChips(activeFilters: $viewModel.activeFilters, onFilterToggled: { viewModel.trackFilterApplied($0) })
            }
            .padding(.top, 14)
            .padding(.bottom, 10)
            .background(
                Color.bgPrimary
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
            )

            // Branch strip OR empty state
            if viewModel.filteredBranches().isEmpty {
                emptyState
                    .background(Color.bgPrimary)
            } else {
                BranchListView(
                    branches: viewModel.filteredBranches(),
                    selectedBranch: viewModel.selectedBranch,
                    distanceLabel: { viewModel.distanceLabel(to: $0) },
                    onSelect: { viewModel.selectBranch($0) }
                )
                .background(Color.bgPrimary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.textMuted)
            Text(viewModel.hasActiveSearchOrFilter
                 ? "No branches match your search or filters."
                 : "No branches available.")
                .font(.custom("Nunito-SemiBold", size: 13))
                .foregroundStyle(.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .accessibilityLabel("No branches found")
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition, selection: .constant(nil)) {
            UserAnnotation()

            ForEach(viewModel.filteredBranches()) { branch in
                Annotation(branch.name, coordinate: branch.coordinate) {
                    BranchAnnotationView(
                        branch: branch,
                        isSelected: viewModel.selectedBranch?.id == branch.id
                    )
                    .onTapGesture { viewModel.selectBranch(branch) }
                    .accessibilityLabel(
                        "\(branch.name), \(branch.isOpen ? "Open" : "Closed"), \(viewModel.distanceLabel(to: branch))"
                    )
                    .accessibilityHint("Double tap to view branch details")
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onTapGesture { viewModel.deselectBranch() }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .semibold))
            Text("Offline — showing saved branches")
                .font(.custom("Nunito-SemiBold", size: 13))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.semanticWarning)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: viewModel.isOffline)
        .accessibilityLabel("You are offline. Showing saved branch data.")
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
        .accessibilityHint("Double tap to move the map back to your current position")
    }
}
