//
//  BranchDetailSheet.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Sticky header gradient, floating CTA, refined info row, polished amenities.
//

import SwiftUI

// MARK: - BranchDetailSheet

struct BranchDetailSheet: View {

    let branch: Branch
    let viewModel: MapViewModel
    let onPickupHere:  () -> Void   // user wants to collect in store
    let onDeliverHere: () -> Void   // user wants rider delivery
    let onDismiss: () -> Void

    @State private var showHours = false
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                dragHandle
                    .padding(.bottom, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 16)

                        infoRow
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        if !branch.amenityIcons.isEmpty {
                            amenitiesSection
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                        }

                        hoursSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        // Spacer so CTA doesn't overlap last content
                        Color.clear.frame(height: 88)
                    }
                }
            }

            // ── Sticky CTA at bottom ────────────────────────────────
            VStack(spacing: 0) {
                // Fade gradient
                LinearGradient(
                    colors: [Color.bgPrimary.opacity(0), Color.bgPrimary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

                ctaButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .background(Color.bgPrimary)
            }
        }
        .background(Color.bgPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .offset(y: appeared ? 0 : 40)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appeared = true
            }
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color.borderColor.opacity(0.8))
            .frame(width: 36, height: 4)
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentPrimary.opacity(0.12))
                    .frame(width: 58, height: 58)

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(Color.accentPrimary)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(branch.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textPrimary)

                Text(branch.address)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.textMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Status
                HStack(spacing: 5) {
                    Circle()
                        .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                        .frame(width: 7, height: 7)
                    Text(branch.isOpen ? "Open Now" : "Closed")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                }
                .padding(.top, 1)
            }

            Spacer()

            // Dismiss
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.textMuted)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle().fill(Color.surfaceSub)
                    )
            }
            .buttonStyle(BounceButtonStyle())
        }
    }

    // MARK: - Info Row

    private var infoRow: some View {
        VStack(spacing: 10) {
            // Quick actions row
            HStack(spacing: 8) {
                let dist = viewModel.distanceLabel(to: branch)
                if !dist.isEmpty {
                    // Distance pill
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(dist)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.surfaceSub)
                    )
                }

                Spacer()

                // Call
                if let phoneURL = URL(string: "tel://\(branch.phone.filter("0123456789+".contains))") {
                    Link(destination: phoneURL) {
                        actionChip("phone.fill", "Call")
                    }
                    .accessibilityLabel("Call \(branch.name)")
                }

                // Directions
                Button { viewModel.openInAppleMaps(branch: branch) } label: {
                    actionChip("map.fill", "Directions")
                }
                .buttonStyle(BounceButtonStyle())
                .accessibilityLabel("Directions to \(branch.name)")
            }

            // Wait time row
            if let waitLabel = branch.waitLabel {
                HStack(spacing: 7) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text(waitLabel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Spacer()
                    Text("Est. wait")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.textMuted)
                }
                .foregroundColor(
                    branch.estimatedWaitMinutes == 0 ? Color.semanticSuccess : Color.accentPrimary
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            (branch.estimatedWaitMinutes == 0
                                ? Color.semanticSuccess
                                : Color.accentPrimary)
                                .opacity(0.1)
                        )
                }
                .accessibilityLabel("Estimated wait: \(waitLabel)")
            }
        }
    }

    private func actionChip(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundColor(Color.accentPrimary)
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(Color.accentPrimary.opacity(0.1))
        )
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Amenities")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)

            HStack(spacing: 10) {
                ForEach(branch.amenityIcons, id: \.label) { amenity in
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.accentPrimary.opacity(0.1))
                                .frame(width: 46, height: 46)
                            Image(systemName: amenity.icon)
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(Color.accentPrimary)
                                .symbolRenderingMode(.hierarchical)
                        }
                        Text(amenity.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.textMuted)
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfacePrimary)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                }
        )
    }

    // MARK: - Hours

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    showHours.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.accentPrimary)
                    Text("Opening Hours")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.textMuted)
                        .rotationEffect(.degrees(showHours ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showHours)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.surfacePrimary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                        }
                )
            }
            .buttonStyle(.plain)

            if showHours {
                BranchHoursView(branch: branch)
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        )
                    )
            }
        }
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Group {
            if !branch.isOpen {
                // Closed — single disabled banner
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                    Text("Branch Closed")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.textMuted))
                .accessibilityLabel("\(branch.name) is currently closed")

            } else {
                // Open — two side-by-side CTAs
                HStack(spacing: 10) {
                    // ── Pickup ───────────────────────────────────────
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        MapAnalytics.branchOrderStarted(
                            branchId: branch.id ?? "unknown",
                            branchName: branch.name
                        )
                        onPickupHere()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                            Text("Pickup")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.accentPrimary.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.accentPrimary.opacity(0.35), lineWidth: 1.5)
                                )
                        }
                    }
                    .buttonStyle(BounceButtonStyle())
                    .accessibilityLabel("Pickup from \(branch.name)")
                    .accessibilityHint("Order now and collect in store")

                    // ── Delivery ─────────────────────────────────────
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        MapAnalytics.branchOrderStarted(
                            branchId: branch.id ?? "unknown",
                            branchName: branch.name
                        )
                        onDeliverHere()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bicycle")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Deliver")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.accentPrimary)
                                .shadow(color: Color.accentPrimary.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                    }
                    .buttonStyle(BounceButtonStyle())
                    .accessibilityLabel("Deliver from \(branch.name)")
                    .accessibilityHint("Rider brings your order to your address")
                }
            }
        }
    }
}
