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
    @Environment(\.dismiss) private var dismiss
    
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
        .background(Color.bgPrimary.ignoresSafeArea())
        .customNavigationBar(user.name, displayMode: .inline) {
            ToolBarButton.back {
                dismiss()
            }
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("bell.badge")) {
                if vm.canSendNotification {
                    vm.showNotifSheet = true
                }
            }
        }
        .sheet(isPresented: $vm.showNotifSheet) { notificationSheet }
        .onAppear { vm.onAppear() }
    }

    // MARK: - Profile Header

    private func profileHeader(data: UserDetailData) -> some View {
        HStack(spacing: 16) {
            // Large avatar with ring
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.accentPrimary.opacity(0.20), Color.accentPrimary.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 68, height: 68)
                Text(user.initials)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.accentPrimary)
            }
            .overlay(Circle().stroke(Color.accentPrimary.opacity(0.22), lineWidth: 2))

            VStack(alignment: .leading, spacing: 5) {
                Text(data.user.name)
                    .font(.title3.bold())
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: 5) {
                    Image(systemName: "envelope")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                    Text(data.user.email)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textMuted)
                    Text("Joined \(data.user.joinDateFormatted)")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }

            Spacer()
        }
        .padding(18)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        // Top accent stripe matching wallet card style
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient.brandPrimary)
                .frame(height: 3)
                .padding(.horizontal, 20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    // MARK: - Stats Row

    private func statsRow(data: UserDetailData) -> some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Orders",
                value: data.user.totalOrdersFormatted,
                icon: "bag.fill",
                color: .accentPrimary
            )
            StatCard(
                title: "Total Spent",
                value: data.user.totalSpentFormatted,
                icon: "dollarsign.circle.fill",
                color: .semanticSuccess
            )
            StatCard(
                title: "Points",
                value: "\(data.user.loyaltyPoints)",
                icon: "star.fill",
                color: .accentGold
            )
        }
    }

    // MARK: - Wallet Card

    private func walletCard(data: UserDetailData) -> some View {
        ChartCard(title: "Wallet Balance", subtitle: "Read-only · Manager view") {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.10))
                        .frame(width: 56, height: 56)
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accentPrimary.opacity(0.75))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(data.walletFormatted)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                    Text("Available balance")
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
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
                VStack(spacing: 8) {
                    Image(systemName: "bag")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.accentPrimary.opacity(0.30))
                    Text("No orders yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(data.recentOrders) { order in
                        UserOrderRow(order: order)
                        if order.id != data.recentOrders.last?.id {
                            Divider().background(Color.borderColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notification Sheet

    private var notificationSheet: some View {
        NavigationStack {
            VStack(spacing: 22) {

                // Title field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Title", systemImage: "text.quote")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    TextField("e.g. Special offer just for you!", text: $vm.notifTitle)
                        .padding(12)
                        .background(Color.surfaceSub, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderColor, lineWidth: 1))
                }

                // Message field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Message", systemImage: "bubble.left.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    TextField("e.g. Enjoy 20% off your next order today.",
                              text: $vm.notifBody, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Color.surfaceSub, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderColor, lineWidth: 1))
                }

                // Send button
                Button {
                    Task { await vm.sendNotification() }
                } label: {
                    HStack(spacing: 8) {
                        if vm.isSendingNotification {
                            ProgressView().tint(.white).scaleEffect(0.85)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text("Send Notification")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        vm.notifFormIsValid
                            ? LinearGradient.brandPrimary
                            : LinearGradient(colors: [Color.secondary.opacity(0.35)],
                                             startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .foregroundStyle(.white)
                    .shadow(color: vm.notifFormIsValid ? Color.accentPrimary.opacity(0.30) : .clear,
                            radius: 8, x: 0, y: 4)
                }
                .disabled(!vm.notifFormIsValid || vm.isSendingNotification)

                Spacer()
            }
            .padding(20)
            .background(Color.bgPrimary.ignoresSafeArea())
            .customNavigationBar("Send to \(user.name)", displayMode: .inline) {
                ToolBarButton.back {
                    dismiss()
                }
                ToolBarButton(placement: .topBarTrailing, buttonType: .text("Cancel")) {
                    vm.showNotifSheet = false
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
            // Status dot
            Circle()
                .fill(order.orderStatus.color)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 2) {
                Text("#\(order.id.suffix(8).uppercased())")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.textPrimary)
                Text("\(order.itemCount) item\(order.itemCount == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(order.totalFormatted)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(order.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.vertical, 10)
    }
}
