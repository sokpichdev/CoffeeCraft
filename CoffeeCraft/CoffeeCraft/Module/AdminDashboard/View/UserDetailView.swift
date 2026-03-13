//
//  UserDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//


//
//  UserDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import SwiftUI

// MARK: - User Detail View

struct UserDetailView: View {

    let user: UserStatItem
    @StateObject private var vm: UserDetailViewModel

    init(user: UserStatItem) {
        self.user = user
        _vm = StateObject(wrappedValue: UserDetailViewModel(user: user))
    }

    var body: some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {
                if vm.isLoading {
                    DashboardLoadingPlaceholder(count: 3)
                } else if let data = vm.detailData {
                    profileHeader(data: data)
                    statsRow(data: data)
                    walletCard(data: data)
                    orderHistorySection(data: data)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.load()
        })
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .sheet(isPresented: $vm.showNotifSheet) { notificationSheet }
        .onAppear { vm.onAppear() }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.showNotifSheet = true
            } label: {
                Image(systemName: "bell.badge")
            }
            .disabled(!vm.canSendNotification)
        }
    }

    // MARK: - Profile Header

    private func profileHeader(data: UserDetailData) -> some View {
        HStack(spacing: 16) {
            // Large avatar
            ZStack {
                Circle()
                    .fill(Color.accentPrimary.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text(user.initials)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.accentPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(data.user.name)
                    .font(.title3.bold())

                Label(data.user.email, systemImage: "envelope")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Label("Joined \(data.user.joinDateFormatted)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats Row

    private func statsRow(data: UserDetailData) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Orders",
                value: data.user.totalOrdersFormatted,
                icon: "bag.fill",
                color: .blue
            )
            StatCard(
                title: "Total Spent",
                value: data.user.totalSpentFormatted,
                icon: "dollarsign.circle.fill",
                color: .green
            )
            StatCard(
                title: "Points",
                value: "\(data.user.loyaltyPoints)",
                icon: "star.fill",
                color: .orange
            )
        }
    }

    // MARK: - Wallet Card

    private func walletCard(data: UserDetailData) -> some View {
        ChartCard(title: "Wallet Balance", subtitle: "Read-only · Manager view") {
            HStack {
                Image(systemName: "wallet.pass.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentPrimary.opacity(0.7))

                VStack(alignment: .leading, spacing: 4) {
                    Text(data.walletFormatted)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Available balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Order History

    private func orderHistorySection(data: UserDetailData) -> some View {
        ChartCard(
            title: "Recent Orders",
            subtitle: "Last \(data.recentOrders.count) orders"
        ) {
            if data.recentOrders.isEmpty {
                Text("No orders yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(data.recentOrders) { order in
                        UserOrderRow(order: order)
                        if order.id != data.recentOrders.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notification Sheet

    private var notificationSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("e.g. Special offer just for you!", text: $vm.notifTitle)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("e.g. Enjoy 20% off your next order today.", text: $vm.notifBody, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }

                Button {
                    Task { await vm.sendNotification() }
                } label: {
                    HStack {
                        if vm.isSendingNotification {
                            ProgressView().tint(.white)
                        }
                        Text("Send Notification")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(vm.notifFormIsValid ? Color.accentPrimary : Color.secondary.opacity(0.4),
                                in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
                }
                .disabled(!vm.notifFormIsValid || vm.isSendingNotification)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Send to \(user.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { vm.showNotifSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - User Order Row

private struct UserOrderRow: View {
    let order: UserOrderItem

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 2) {
                Text("#\(order.id.prefix(8).uppercased())")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospaced()
                Text("\(order.itemCount) item\(order.itemCount == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(order.totalFormatted)
                    .font(.subheadline.weight(.semibold))
                Text(order.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 10)
    }

    private var statusColor: Color {
        switch order.statusColor {
        case .green:     return .green
        case .orange:    return .orange
        case .blue:      return .blue
        case .teal:      return .teal
        case .red:       return .red
        case .secondary: return .secondary
        }
    }
}