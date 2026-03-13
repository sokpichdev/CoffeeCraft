//
//  UserManagementView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import SwiftUI

// MARK: - User Management View

struct UserManagementView: View {

    @StateObject private var vm = UserManagementViewModel()

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            content
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { vm.onAppear() }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search by name or email", text: $vm.searchText)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .onSubmit { Task { await vm.applySearch() } }
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                    Task { await vm.applySearch() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            userListSkeleton
        } else if vm.users.isEmpty {
            DashboardEmptyState(
                icon: "person.2.slash",
                title: "No customers found",
                message: vm.searchText.isEmpty
                    ? "No customer accounts registered yet."
                    : "No results for \"\(vm.searchText)\"."
            )
        } else {
            userList
        }
    }

    // MARK: - User List

    private var userList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Column header
                columnHeader

                ForEach(vm.users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        UserListRow(user: user)
                    }
                    .buttonStyle(.plain)

                    // Trigger load-more when last row appears
                    if user.id == vm.users.last?.id {
                        Color.clear.frame(height: 1)
                            .onAppear { Task { await vm.loadMore() } }
                    }

                    Divider().padding(.leading, 56)
                }

                if vm.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else if !vm.canLoadMore && vm.users.count >= 20 {
                    Text("All \(vm.users.count) users loaded")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
        }
        .refreshable { await vm.load() }
    }

    private var columnHeader: some View {
        HStack {
            Text("Customer")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 56)
            Text("Orders")
                .frame(width: 52, alignment: .trailing)
            Text("Spent")
                .frame(width: 72, alignment: .trailing)
            Text("Points")
                .frame(width: 52, alignment: .trailing)
                .padding(.trailing, 16)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemBackground))
    }

    // MARK: - Skeleton Loading

    private var userListSkeleton: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { _ in
                    UserListRowSkeleton()
                    Divider().padding(.leading, 56)
                }
            }
        }
    }
}

// MARK: - User List Row

struct UserListRow: View {
    let user: UserStatItem

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.15))
                    .frame(width: 38, height: 38)
                Text(user.initials)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accentPrimary)
            }

            // Name + email
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Total orders
            enrichedValue(user.totalOrdersFormatted)
                .frame(width: 52, alignment: .trailing)

            // Total spent
            enrichedValue(user.totalSpentFormatted)
                .frame(width: 72, alignment: .trailing)

            // Loyalty points
            Text("\(user.loyaltyPoints)")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func enrichedValue(_ text: String) -> some View {
        if text == "—" {
            // Still loading enrichment
            ShimmerView()
                .frame(width: 28, height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - User List Row Skeleton

private struct UserListRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerView()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                ShimmerView().frame(width: 120, height: 13).clipShape(Capsule())
                ShimmerView().frame(width: 160, height: 11).clipShape(Capsule())
            }
            Spacer()
            ShimmerView().frame(width: 28, height: 13).clipShape(Capsule())
            ShimmerView().frame(width: 42, height: 13).clipShape(Capsule())
            ShimmerView().frame(width: 28, height: 13).clipShape(Capsule())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
