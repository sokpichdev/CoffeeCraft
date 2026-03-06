//
//  MapView.swift
//  CoffeeCraft
//
//  Map Module — Phase 4
//  Added: offline banner when isOffline == true.
//  Added: stopListening() on disappear.
//  Everything else unchanged from Phase 3.
//

import SwiftUI
import MapKit

// MARK: - MapView

struct MapView: View {

    @State private var viewModel = MapViewModel()
    @EnvironmentObject private var orderEnv: OrderEnvironment
    @Binding var selectedTab: Tab

    init(selectedTab: Binding<Tab> = .constant(.home)) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

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
                    recenterButton
                        .padding(.bottom, 188)
                        .padding(.trailing, 16)
                }

                // MARK: Branch strip
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
                            orderEnv.select(branch: branch)
                            viewModel.isSheetPresented = false
                            withAnimation(.easeInOut) { selectedTab = .menu }
                        },
                        onDismiss: {
                            viewModel.deselectBranch()
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.bgPrimary)
                }
            }
        }
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
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition, selection: .constant(nil)) {
            UserAnnotation()

            ForEach(viewModel.branches) { branch in
                Annotation(branch.name, coordinate: branch.coordinate) {
                    BranchAnnotationView(
                        branch: branch,
                        isSelected: viewModel.selectedBranch?.id == branch.id
                    )
                    .onTapGesture { viewModel.selectBranch(branch) }
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

// MARK: - Preview

#Preview {
    MapView()
        .environmentObject(OrderEnvironment.shared)
}
