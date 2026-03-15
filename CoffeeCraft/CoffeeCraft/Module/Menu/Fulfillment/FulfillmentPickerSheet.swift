//
//  FulfillmentPickerSheet.swift
//  CoffeeCraft
//
//  Presented immediately after the user picks a branch (from MenuBranchSelectionSheet
//  or from the Map tab's "Order from here" shortcut).
//
//  Step 1: Choose Pickup or Delivery.
//  Step 2 (Delivery only): Pick / confirm delivery address via DeliveryDestinationPicker.
//  On confirm → writes to OrderEnvironment and dismisses.
//

import CoreLocation
import SwiftUI

struct FulfillmentPickerSheet: View {

    let branch: Branch

    @EnvironmentObject private var orderEnv: OrderEnvironment
    @Environment(\.dismiss) private var dismiss

    // Location dependencies for the delivery address step
    @State private var locationManager  = SavedLocationManager()
    @State private var userCoordinate: CLLocationCoordinate2D? = nil
    @State private var locationFetcher  = LocationFetcher()

    // Navigation inside the sheet
    @State private var showAddressPicker = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    dragHandle

                    // Branch header
                    branchHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 28)

                    // Mode cards
                    VStack(spacing: 12) {
                        modeCard(
                            icon:     "bag.fill",
                            title:    "Pickup",
                            subtitle: "Walk in and collect at the counter",
                            color:    Color.accentPrimary
                        ) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            orderEnv.selectPickup(branch: branch)
                            dismiss()
                        }

                        modeCard(
                            icon:     "bicycle",
                            title:    "Delivery",
                            subtitle: "Rider brings it to your door",
                            color:    Color.semanticSuccess
                        ) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showAddressPicker = true
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showAddressPicker) {
                DeliveryDestinationPicker(
                    branch:          branch,
                    locationManager: locationManager,
                    userCoordinate:  userCoordinate,
                    onConfirm: { coordinate, label in
                        orderEnv.selectDelivery(
                            branch:       branch,
                            addressLabel: label,
                            destination:  coordinate
                        )
                        dismiss()
                    },
                    onCancel: {
                        showAddressPicker = false
                    }
                )
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(26)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgPrimary)
        .onAppear {
            if let userId = UserSession.shared.userId {
                Task { await locationManager.fetchLocations(for: userId) }
            }
            locationFetcher.requestLocation { coord in
                userCoordinate = coord
            }
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color.borderColor.opacity(0.8))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Branch Header

    private var branchHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.accentPrimary.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color.accentPrimary)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("How would you like your order?")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.textMuted)
                    .textCase(.uppercase)
                    .tracking(0.4)
                Text(branch.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)
                    .lineLimit(1)
                Text(branch.address)
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    // MARK: - Mode Card

    private func modeCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(color)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.textMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.textMuted.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - LocationFetcher
// Lightweight one-shot CLLocationManager wrapper used only by FulfillmentPickerSheet.

@Observable
final class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            completion(nil)
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        completion?(locations.last?.coordinate)
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
        completion = nil
    }
}
