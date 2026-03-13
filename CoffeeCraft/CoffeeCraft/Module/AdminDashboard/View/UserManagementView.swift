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
            Divider().background(Color.borderColor)
            content
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { vm.onAppear() }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.textMuted)
            TextField("Search by name or email", text: $vm.searchText)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .onSubmit { Task { await vm.applySearch() } }
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                    Task { await vm.applySearch() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.surfaceSub, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.bgSecondary)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        CustomRefreshScrollView({
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
        }, onRefresh: {
            await vm.load()
        })
    }

    // MARK: - User List

    private var userList: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            Section {
                ForEach(vm.users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        UserListRow(user: user)
                    }
                    .buttonStyle(.plain)
                    
                    if user.id == vm.users.last?.id {
                        Color.clear.frame(height: 1)
                            .onAppear { Task { await vm.loadMore() } }
                    }
                    
                    Divider().padding(.leading, 58).background(Color.borderColor)
                }
                
                if vm.isLoadingMore {
                    ProgressView().tint(.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else if !vm.canLoadMore && vm.users.count >= 20 {
                    Text("All \(vm.users.count) users loaded")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            } header: {
                columnHeader
            }
        }
    }

    private var columnHeader: some View {
        HStack {
            Text("Customer")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 58)
            Text("Orders")
                .frame(width: 52, alignment: .trailing)
            Text("Spent")
                .frame(width: 72, alignment: .trailing)
            Text("Points")
                .frame(width: 52, alignment: .trailing)
                .padding(.trailing, 16)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.textMuted)
        .tracking(0.3)
        .padding(.vertical, 9)
        .padding(.horizontal, 16)
        .background(Color.bgSecondary)
        .overlay(alignment: .bottom) {
            Divider().background(Color.borderColor)
        }
    }

    // MARK: - Skeleton

    private var userListSkeleton: some View {
        VStack(spacing: 0) {
            ForEach(0..<12, id: \.self) { _ in
                UserListRowSkeleton()
                Divider().padding(.leading, 58).background(Color.borderColor)
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
                    .fill(Color.accentPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Text(user.initials)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.accentPrimary)
            }

            // Name + email
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            enrichedValue(user.totalOrdersFormatted)
                .frame(width: 52, alignment: .trailing)

            enrichedValue(user.totalSpentFormatted)
                .frame(width: 72, alignment: .trailing)

            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.accentGold)
                Text("\(user.loyaltyPoints)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(width: 52, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func enrichedValue(_ text: String) -> some View {
        if text == "—" {
            ShimmerView()
                .frame(width: 28, height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
        }
    }
}

// MARK: - User List Row Skeleton

private struct UserListRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerView().frame(width: 40, height: 40).clipShape(Circle())
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
