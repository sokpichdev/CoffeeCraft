//
//  BranchDetailSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 3: Branch Selection + Routing
//

import SwiftUI
import MapKit

// MARK: - BranchDetailSheet

struct BranchDetailSheet: View {

    let branch: Branch
    let distanceLabel: String
    let etaLabel: String             // e.g. "~8 min drive"
    let onOrderHere: () -> Void
    let onDismiss: () -> Void

    @State private var showHours = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Drag handle ─────────────────────────────────────────
            dragHandle

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Header ──────────────────────────────────────
                    headerSection

                    Divider().opacity(0.5)

                    // ── ETA + distance ──────────────────────────────
                    if !etaLabel.isEmpty || !distanceLabel.isEmpty {
                        routeInfoSection
                        Divider().opacity(0.5)
                    }

                    // ── Amenities ───────────────────────────────────
                    if !branch.amenityIcons.isEmpty {
                        amenitiesSection
                        Divider().opacity(0.5)
                    }

                    // ── Opening hours (collapsible) ──────────────────
                    hoursSection

                    // ── CTA buttons ─────────────────────────────────
                    ctaButtons
                        .padding(.bottom, 8)
                }
                .padding(20)
            }
        }
        .background(Color.bgPrimary)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }

    // MARK: - Subviews

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.border)
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentPrimary.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(branch.name)
                    .font(.custom("Nunito-Bold", size: 18))
                    .foregroundStyle(.textPrimary)

                Text(branch.address)
                    .font(.custom("Nunito-Regular", size: 13))
                    .foregroundStyle(.textMuted)
                    .lineLimit(2)

                // Open / Closed badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                        .frame(width: 7, height: 7)
                    Text(branch.isOpen ? "Open Now" : "Closed")
                        .font(.custom("Nunito-SemiBold", size: 12))
                        .foregroundStyle(branch.isOpen ? .semanticSuccess : .semanticError)
                }
            }

            Spacer()

            // Dismiss X
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.textMuted)
                    .frame(width: 28, height: 28)
                    .background(Color.surfaceSub)
                    .clipShape(Circle())
            }
        }
    }

    private var routeInfoSection: some View {
        HStack(spacing: 20) {
            if !etaLabel.isEmpty {
                Label(etaLabel, systemImage: "car.fill")
                    .font(.custom("Nunito-SemiBold", size: 13))
                    .foregroundStyle(.textSecondary)
            }
            if !distanceLabel.isEmpty {
                Label(distanceLabel, systemImage: "location.fill")
                    .font(.custom("Nunito-SemiBold", size: 13))
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Amenities")
                .font(.custom("Nunito-Bold", size: 14))
                .foregroundStyle(.textPrimary)

            HStack(spacing: 10) {
                ForEach(branch.amenityIcons, id: \.label) { amenity in
                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.surfaceSub)
                                .frame(width: 44, height: 44)
                            Image(systemName: amenity.icon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.accentPrimary)
                        }
                        Text(amenity.label)
                            .font(.custom("Nunito-Regular", size: 10))
                            .foregroundStyle(.textMuted)
                    }
                }
            }
        }
    }

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Collapsible header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showHours.toggle()
                }
            } label: {
                HStack {
                    Text("Opening Hours")
                        .font(.custom("Nunito-Bold", size: 14))
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Image(systemName: showHours ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.textMuted)
                }
            }
            .buttonStyle(.plain)

            if showHours {
                BranchHoursView(branch: branch)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var ctaButtons: some View {
        HStack(spacing: 12) {
            // Get Directions
            Button(action: openInMaps) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Directions")
                        .font(.custom("Nunito-SemiBold", size: 15))
                }
                .foregroundStyle(.accentPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentPrimary.opacity(0.1))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.accentPrimary.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityLabel("Get directions to \(branch.name) in Apple Maps")

            // Order from here
            Button(action: onOrderHere) {
                HStack(spacing: 6) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Order Here")
                        .font(.custom("Nunito-Bold", size: 15))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    branch.isOpen
                        ? Color.accentPrimary
                        : Color.textMuted
                )
                .cornerRadius(14)
            }
            .disabled(!branch.isOpen)
            .accessibilityLabel(
                branch.isOpen
                    ? "Order from \(branch.name)"
                    : "\(branch.name) is currently closed"
            )
        }
    }

    // MARK: - Helpers

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: branch.coordinate)
        let mapItem   = MKMapItem(placemark: placemark)
        mapItem.name  = branch.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

//// MARK: - Preview
//
//#Preview {
//    ZStack(alignment: .bottom) {
//        Color.black.opacity(0.3).ignoresSafeArea()
//        BranchDetailSheet(
//            branch: MockBranchData.all[1],
//            distanceLabel: "2.3 km",
//            etaLabel: "~8 min drive",
//            onOrderHere: {},
//            onDismiss: {}
//        )
//    }
//}
