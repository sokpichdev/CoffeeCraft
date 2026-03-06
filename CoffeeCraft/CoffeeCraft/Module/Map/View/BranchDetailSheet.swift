//
//  BranchDetailSheet.swift
//  CoffeeCraft
//
//  Map Module — Simplified
//  Branch detail: header, hours, amenities, phone, Apple Maps link, Order CTA.
//  Route info and directions view removed — Phase 5+.
//

import SwiftUI

// MARK: - BranchDetailSheet

struct BranchDetailSheet: View {

    let branch: Branch
    let viewModel: MapViewModel
    let onOrderHere: () -> Void
    let onDismiss: () -> Void

    @State private var showHours = false

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    Divider().opacity(0.5)

                    infoRow
                    Divider().opacity(0.5)

                    if !branch.amenityIcons.isEmpty {
                        amenitiesSection
                        Divider().opacity(0.5)
                    }

                    hoursSection
                    ctaButtons.padding(.bottom, 8)
                }
                .padding(20)
            }
        }
        .background(Color.bgPrimary)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.border)
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Header

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

            // Name + address + status
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

    // MARK: - Info Row (distance + phone + Apple Maps)

    private var infoRow: some View {
        HStack(spacing: 16) {
            // Distance
            let distance = viewModel.distanceLabel(to: branch)
            if !distance.isEmpty {
                Label(distance, systemImage: "location.fill")
                    .font(.custom("Nunito-SemiBold", size: 13))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            // Phone call
            if let phoneURL = URL(string: "tel://\(branch.phone.filter("0123456789+".contains))") {
                Link(destination: phoneURL) {
                    HStack(spacing: 5) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Call")
                            .font(.custom("Nunito-SemiBold", size: 13))
                    }
                    .foregroundStyle(.accentPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.accentPrimary.opacity(0.1))
                    .cornerRadius(10)
                }
                .accessibilityLabel("Call \(branch.name)")
            }

            // Apple Maps
            Button {
                viewModel.openInAppleMaps(branch: branch)
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Directions")
                        .font(.custom("Nunito-SemiBold", size: 13))
                }
                .foregroundStyle(.accentPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.accentPrimary.opacity(0.1))
                .cornerRadius(10)
            }
            .accessibilityLabel("Get directions to \(branch.name) in Apple Maps")
        }
    }

    // MARK: - Amenities

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

    // MARK: - Hours

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { showHours.toggle() }
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

    // MARK: - CTA

    private var ctaButtons: some View {
        Button(action: onOrderHere) {
            HStack(spacing: 8) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text(branch.isOpen ? "Order from Here" : "Branch Closed")
                    .font(.custom("Nunito-Bold", size: 16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(branch.isOpen ? Color.accentPrimary : Color.textMuted)
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

// MARK: - Preview

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.opacity(0.3).ignoresSafeArea()
        BranchDetailSheet(
            branch: MockBranchData.all[1],
            viewModel: MapViewModel(),
            onOrderHere: {},
            onDismiss: {}
        )
    }
}
