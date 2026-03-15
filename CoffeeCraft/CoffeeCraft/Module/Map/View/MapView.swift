//
//  MapView.swift
//  CoffeeCraft
//
//  Map Module — Branch Explorer
//
//  The map is a read-only branch explorer. It shows branch locations, hours,
//  amenities, and quick actions (Call, Directions). The ordering flow starts
//  in the Menu tab — the Map's only ordering hook is the "Order from here"
//  button in BranchDetailSheet, which calls orderEnv.preSelectBranch() and
//  switches the app to the Menu tab via onSwitchToMenu.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {

    @State private var viewModel = MapViewModel()

    /// Switches the root tab to .menu. Injected from RootView / TabBarView.
    var onSwitchToMenu: (() -> Void)?

    @EnvironmentObject private var orderEnv: OrderEnvironment

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Map / Permission ────────────────────────────────────
            Group {
                if viewModel.isPermissionDenied {
                    MapPermissionDeniedView()
                } else {
                    mapLayer
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // ── Offline banner ──────────────────────────────────────
            if viewModel.isOffline {
                VStack {
                    offlineBanner
                        .padding(.top, 56)
                        .padding(.horizontal, 16)
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isOffline)
            }

            // ── Recenter button ─────────────────────────────────────
            if viewModel.isPermissionGranted {
                HStack {
                    Spacer()
                    recenterButton
                        .padding(.bottom, viewModel.filteredBranches().isEmpty ? 180 : 318)
                        .padding(.trailing, 16)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.72),
                           value: viewModel.filteredBranches().count)
            }

            // ── Bottom panel ────────────────────────────────────────
            bottomPanel
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.requestLocationPermission()
            viewModel.fetchBranches()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .sheet(isPresented: $viewModel.isSheetPresented,
               onDismiss: { viewModel.deselectBranch() }) {
            if let branch = viewModel.selectedBranch {
                BranchDetailSheet(
                    branch: branch,
                    viewModel: viewModel,
                    onOrderHere: {
                        // 1. Pre-select the branch in OrderEnvironment.
                        //    MenuView will detect pendingMapBranch and show FulfillmentPickerSheet.
                        orderEnv.preSelectBranch(branch)
                        // 2. Dismiss this sheet.
                        viewModel.isSheetPresented = false
                        // 3. Switch to the Menu tab.
                        onSwitchToMenu?()
                    },
                    onDismiss: { viewModel.deselectBranch() }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(26)
                .presentationBackground(Color.bgPrimary)
            }
        }
        .customNavigationBar("Find a Branch", hideBackBtn: false)
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                MapSearchBar(text: .init(
                    get: { viewModel.searchQuery },
                    set: { viewModel.updateSearchQuery($0) }
                )) {
                    viewModel.updateSearchQuery("")
                }
                .padding(.horizontal, 16)

                MapFilterChips(
                    activeFilters: $viewModel.activeFilters,
                    onFilterToggled: { viewModel.trackFilterApplied($0) }
                )
            }
            .padding(.top, 16)
            .padding(.bottom, 10)

            if viewModel.filteredBranches().isEmpty {
                emptyState
            } else {
                BranchListView(
                    branches: viewModel.filteredBranches(),
                    selectedBranch: viewModel.selectedBranch,
                    distanceLabel: { viewModel.distanceLabel(to: $0) },
                    onSelect: { viewModel.selectBranch($0) }
                )
            }
        }
        .background(
            ZStack {
                Color.bgPrimary.opacity(0.92)
                    .background(.ultraThinMaterial)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .path(in: CGRect(x: -40, y: 0,
                                    width: UIScreen.main.bounds.width + 80,
                                    height: 500))
            )
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.borderColor.opacity(0.4))
                    .frame(width: 40, height: 3)
                    .padding(.top, 8)
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -6)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.textMuted)
            Text(viewModel.hasActiveSearchOrFilter
                 ? "No branches match your search."
                 : "No branches available.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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
            // Note: Saved delivery address pins are NOT shown here.
            // They are only relevant during delivery address selection
            // in FulfillmentPickerSheet (DeliveryDestinationPicker).
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
                .font(.system(size: 12, weight: .semibold))
            Text("Offline — showing saved branches")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.semanticWarning)
                .shadow(color: Color.semanticWarning.opacity(0.45), radius: 12, x: 0, y: 4)
        )
        .accessibilityLabel("You are offline. Showing saved branch data.")
    }

    // MARK: - Recenter Button

    private var recenterButton: some View {
        Button(action: viewModel.recenterOnUser) {
            Image(systemName: "location.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.accentPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.regularMaterial)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 4)
                )
        }
        .buttonStyle(BounceButtonStyle())
        .accessibilityLabel("Re-center map on my location")
    }
}
