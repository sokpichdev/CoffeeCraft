//
//  MapView.swift
//  CoffeeCraft
//
//  Map Module — Phase 4 (Delivery)
//  Glass bottom panel with ultraThinMaterial, floating recenter pill, animated offline toast.
//  Phase 4: "Order from Here" builds a DeliverySession and navigates to DeliveryMapView.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {

    @State private var viewModel         = MapViewModel()
    @State private var localSearch       = ""
    @State private var navigateToDelivery    = false
    @State private var locationManager       = SavedLocationManager()
    @State private var pendingBranch: Branch? = nil   // set when sheet is dismissed, before picker
    @State private var showDestinationPicker = false
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

            // ── Offline banner (top toast) ──────────────────────────
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
                .animation(.spring(response: 0.35, dampingFraction: 0.72), value: viewModel.filteredBranches().count)
            }

            // ── Bottom panel ────────────────────────────────────────
            bottomPanel
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.requestLocationPermission()
            viewModel.fetchBranches()
            if let userId = UserSession.shared.userId {
                Task { await locationManager.fetchLocations(for: userId) }
            }
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
                    onPickupHere: {
                        // Pickup: set branch + mode immediately, dismiss sheet.
                        // orderEnv write is safe — MenuBranchSelectionSheet guards
                        // on activeDeliverySession == nil before auto-dismissing.
                        orderEnv.selectPickup(branch: branch)
                        viewModel.isSheetPresented = false
                    },
                    onDeliverHere: {
                        // Delivery: store branch, dismiss sheet, show destination picker.
                        pendingBranch = branch
                        viewModel.isSheetPresented = false
                    },
                    onDismiss: { viewModel.deselectBranch() }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(26)
                .presentationBackground(Color.bgPrimary)
            }
        }
        // ── Destination picker — shown after "Order from Here" ────────
        .sheet(isPresented: $showDestinationPicker) {
            if let branch = pendingBranch {
                DeliveryDestinationPicker(
                    branch:          branch,
                    locationManager: locationManager,
                    userCoordinate:  viewModel.userLocation?.coordinate,
                    onConfirm: { destination, addressLabel in
                        showDestinationPicker = false
                        orderEnv.selectDelivery(branch: branch, addressLabel: addressLabel)
                        let orderId = generateOrderId()
                        let session = DeliverySession(
                            orderId:               orderId,
                            branchId:              branch.id ?? "unknown",
                            branchCoordinate:      branch.coordinate,
                            destinationCoordinate: destination
                        )
                        orderEnv.startDelivery(session: session)
                        navigateToDelivery = true
                    },
                    onCancel: {
                        showDestinationPicker = false
                        pendingBranch         = nil
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(26)
                .presentationBackground(Color.bgPrimary)
            }
        }
        // Show picker once BranchDetailSheet is fully dismissed
        .onChange(of: viewModel.isSheetPresented) { _, isPresented in
            if !isPresented, pendingBranch != nil {
                showDestinationPicker = true
            }
        }
        // ── Delivery tracking push ──────────────────────────────────
        .navigationDestination(isPresented: $navigateToDelivery) {
            if let vm = orderEnv.activeDeliveryVM {
                DeliveryMapView(vm: vm)
            }
        }
        .customNavigationBar("Find a Branch", hideBackBtn: false)
    }

    // MARK: - Order ID helper

    private func generateOrderId() -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let datePart         = formatter.string(from: Date())
        let suffix           = String(format: "%03d", Int.random(in: 1 ... 999))
        return "\(datePart)-\(suffix)"
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            // Search + filters
            VStack(spacing: 8) {
                MapSearchBar(text: $localSearch) {
                    viewModel.searchQuery = ""
                }
                .padding(.horizontal, 16)
                .onChange(of: localSearch) { _, new in
                    viewModel.updateSearchQuery(new)
                }

                MapFilterChips(
                    activeFilters: $viewModel.activeFilters,
                    onFilterToggled: { viewModel.trackFilterApplied($0) }
                )
            }
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Branch strip or empty state
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
            // Layered glass background
            ZStack {
                Color.bgPrimary.opacity(0.92)
                    .background(.ultraThinMaterial)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .path(in: CGRect(x: -40, y: 0, width: UIScreen.main.bounds.width + 80, height: 500))
            )
            .overlay(alignment: .top) {
                // Subtle top edge line
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
            // ── Saved delivery address pins ─────────────────────────
            ForEach(locationManager.locations) { location in
                Annotation(location.label, coordinate: location.coordinate) {
                    SavedLocationAnnotationView(location: location, isSelected: false)
                        .accessibilityLabel("\(location.label): \(location.address)")
                        .accessibilityHint("Saved delivery address")
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

    // MARK: - Offline Banner (toast pill style)

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

    // MARK: - Recenter Button (pill style)

    private var recenterButton: some View {
        Button(action: viewModel.recenterOnUser) {
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.accentPrimary)
            }
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
