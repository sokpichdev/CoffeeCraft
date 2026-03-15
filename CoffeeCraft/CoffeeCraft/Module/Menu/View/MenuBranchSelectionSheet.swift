//
//  MenuBranchSelectionSheet.swift
//  CoffeeCraft
//
//  Presents a list of branches. When the user selects one, this sheet dismisses
//  and FulfillmentPickerSheet is presented by MenuView to capture Pickup/Delivery.
//

import SwiftUI

struct MenuBranchSelectionSheet: View {

    @EnvironmentObject private var orderEnv: OrderEnvironment
    @Environment(\.dismiss)  private var dismiss
    @State private var branches: [Branch]  = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var navigateToMap = false

    // Callback: MenuView uses this to know which branch was chosen so it can
    // immediately present FulfillmentPickerSheet.
    var onBranchSelected: ((Branch) -> Void)?

    private var filteredBranches: [Branch] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return branches }
        return branches.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if filteredBranches.isEmpty {
                    emptyView
                } else {
                    branchList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .customNavigationBar("Select a Store") {
                ToolBarButton.back { dismiss() }
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("map.fill")) {
                    navigateToMap = true
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by name or address"
            )
            .navigationDestination(isPresented: $navigateToMap) {
                MapView(onSwitchToMenu: {
                    // Branch was pre-selected via map; dismiss this whole sheet stack.
                    // MenuView will detect orderEnv.pendingMapBranch and show FulfillmentPickerSheet.
                    dismiss()
                })
                .environmentObject(orderEnv)
            }
        }
        .onAppear { fetchBranches() }
    }

    // MARK: - Branch List

    private var branchList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredBranches) { branch in
                    BranchRowCard(branch: branch) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        // Dismiss first; MenuView's onDismiss will present the picker.
                        onBranchSelected?(branch)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Loading (shimmer placeholders)

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { _ in
                    ShimmerView(cornerRadius: 18)
                        .frame(height: 92)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "mappin.slash.circle.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(Color.accentPrimary)
                    .symbolRenderingMode(.hierarchical)
            }

            Text(searchText.isEmpty ? "No Stores Available" : "No Results")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)

            Text(searchText.isEmpty
                 ? "Check back soon — we're expanding."
                 : "Try a different name or address.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func fetchBranches() {
        isLoading = true
        BranchRepository.shared.listen { updated in
            DispatchQueue.main.async {
                self.branches  = updated
                self.isLoading = false
            }
        }
    }
}

// MARK: - BranchRowCard

struct BranchRowCard: View {
    let branch: Branch
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {

                // ── Icon tile ───────────────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            branch.isOpen
                                ? Color.accentPrimary.opacity(0.12)
                                : Color.surfaceSub
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(branch.isOpen ? Color.accentPrimary : Color.textMuted)
                        .symbolRenderingMode(.hierarchical)
                }

                // ── Info ────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text(branch.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(1)

                    Text(branch.address)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.textMuted)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        // Open / closed
                        HStack(spacing: 4) {
                            Circle()
                                .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                                .frame(width: 6, height: 6)
                            Text(branch.isOpen ? "Open" : "Closed")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                        }

                        // Amenity chips (max 2)
                        ForEach(branch.amenityIcons.prefix(2), id: \.label) { amenity in
                            HStack(spacing: 3) {
                                Image(systemName: amenity.icon)
                                    .font(.system(size: 9))
                                Text(amenity.label)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Color.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.surfaceSub)
                            )
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.textMuted.opacity(0.5))
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            }
        }
        .buttonStyle(BounceButtonStyle())
        .accessibilityLabel("\(branch.name), \(branch.isOpen ? "Open" : "Closed"), \(branch.address)")
        .accessibilityHint("Double tap to select this store")
    }
}
