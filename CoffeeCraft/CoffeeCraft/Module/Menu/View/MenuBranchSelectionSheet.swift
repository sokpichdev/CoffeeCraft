//
//  MenuBranchSelectionSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.

import SwiftUI

struct MenuBranchSelectionSheet: View {

    @EnvironmentObject private var orderEnv: OrderEnvironment
    @Environment(\.dismiss)  private var dismiss
    @Environment(\.pushScreen) var push
    @State private var branches: [Branch]  = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var navigateToMap = false

    private var filteredBranches: [Branch] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return branches }
        return branches.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }
    }
    
    var body: some View {
        // Native NavigationStack scopes navigation entirely within the sheet.
        // CustomNavigationStack / push resolves to the root app navigator (behind
        // the sheet) — that is why the map was appearing behind. navigationDestination
        // keeps everything inside this modal presentation.
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
                ToolBarButton.back {
                    dismiss()
                }
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("map.fill")) {
                    navigateToMap = true
//                    push(AnyView(MapView().environmentObject(orderEnv)))
                }
            }
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search by name or address")
            .navigationDestination(isPresented: $navigateToMap) {
                MapView()
                    .environmentObject(orderEnv)
            }
        }
        .onAppear { fetchBranches() }
        .onChange(of: orderEnv.selectedBranch) { _, newBranch in
            if newBranch != nil { dismiss() }
        }
    }

    private var branchList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredBranches) { branch in
                    BranchRowCard(branch: branch) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        orderEnv.select(branch: branch)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ForEach(0..<4, id: \.self) { _ in
                ShimmerView(cornerRadius: 16)
                    .frame(height: 88)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.slash.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.textMuted)
            Text(searchText.isEmpty ? "No stores available" : "No stores match your search")
                .font(.subheadline)
                .foregroundStyle(.textMuted)
                .multilineTextAlignment(.center)
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

struct BranchRowCard: View {
    let branch: Branch
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(branch.isOpen
                              ? Color.accentPrimary.opacity(0.12)
                              : Color.surfaceSub)
                        .frame(width: 48, height: 48)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(branch.isOpen ? .accentPrimary : .textMuted)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(branch.name)
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)

                    Text(branch.address)
                        .font(.caption)
                        .foregroundStyle(.textMuted)
                        .lineLimit(1)

                    // Status + amenity chips
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(branch.isOpen ? Color.semanticSuccess : Color.semanticError)
                                .frame(width: 6, height: 6)
                            Text(branch.isOpen ? "Open" : "Closed")
                                .font(.caption2).fontWeight(.semibold)
                                .foregroundStyle(branch.isOpen ? .semanticSuccess : .semanticError)
                        }

                        ForEach(branch.amenityIcons.prefix(2), id: \.label) { amenity in
                            HStack(spacing: 3) {
                                Image(systemName: amenity.icon)
                                    .font(.system(size: 9))
                                Text(amenity.label)
                                    .font(.caption2)
                            }
                            .foregroundStyle(.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.surfaceSub)
                            .cornerRadius(5)
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.textMuted)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfacePrimary)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.border, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(branch.name), \(branch.isOpen ? "Open" : "Closed"), \(branch.address)")
        .accessibilityHint("Double tap to select this store")
    }
}
