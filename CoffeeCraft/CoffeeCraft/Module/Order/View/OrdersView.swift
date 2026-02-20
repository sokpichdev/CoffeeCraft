//
//  OrdersView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/23/25.
//
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var coordinator: NotificationCoordinator
    @Environment(\.pushScreen) private var push   // ← replace navigationPath
    @State private var isPaginating = false
    @State private var pageNum = 1

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            if orderVM.orders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.brown.opacity(0.7))
                    Text("No Orders Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Your recent coffee orders will appear here.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                CustomRefreshScrollView({
                    LazyVStack(spacing: 8) {
                        ForEach(Array(orderVM.orders.enumerated()), id: \.element.id) { _, order in
                            PushLink(value: order) { order in  // ← PushLink replaces Button
                                OrderDetailView(order: order)
                            } label: {
                                OrderCardView(order: order)
                                    .padding(.horizontal)
                            }
                            .onAppear {
                                if orderVM.orders.count < orderVM.totalOrdersCount {
                                    if !orderVM.orders.isEmpty {
                                        if order.id == orderVM.orders.last?.id, !isPaginating {
                                            isPaginating = true
                                            pageNum += 1
                                            Task {
                                                let timer = MinimumLoadingTime(0.5)
                                                try? await timer.waitIfNeeded()
                                                await MainActor.run {
                                                    orderVM.fetchOrders(pageNum: pageNum) { _ in
                                                        isPaginating = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if isPaginating {
                            ProgressView().padding()
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                }, onRefresh: {
                    pageNum = 1
                    await withCheckedContinuation { continuation in
                        orderVM.refreshOrders { _ in continuation.resume() }
                    }
                })
            }
        }
        .customNavigationBar("My Orders")
        .onAppear {
            orderVM.fetchOrders(pageNum: 1)
            handleDeepLink()
        }
        .onChange(of: coordinator.selectedOrderId) { _, _ in
            handleDeepLink()
        }
    }

    private func handleDeepLink() {
        guard let orderId = coordinator.selectedOrderId else { return }

        func navigate() {
            if let order = orderVM.orders.first(where: { $0.id == orderId }) {
                push(AnyView(OrderDetailView(order: order)))  // ← push instead of navigationPath.append
                coordinator.clearNavigation()
            }
        }

        if orderVM.orders.contains(where: { $0.id == orderId }) {
            navigate()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                navigate()
            }
        }
    }
}

struct OrderCardView: View {
    let order: Order
    var adminActions: (() -> AnyView)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Order #\(order.orderId)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(order.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(statusColor(order.status).opacity(0.15))
                    .foregroundColor(statusColor(order.status))
                    .clipShape(Capsule())
            }

            Divider()

            // Items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("$\(item.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        // Selections
                        if let selections = item.selections, !selections.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(selections.keys.sorted(), id: \.self) { key in
                                    if let value = selections[key] {
                                        HStack(spacing: 8) {
                                            Text("\(key):")
                                            Text(value)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                        }

                        // Extras
                        if let extras = item.extras, !extras.isEmpty {
                            HStack(spacing: 8) {
                                Text("Extras:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(extras, id: \.self) { extra in
                                    HStack(spacing: 0) {
                                        Text(extra)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        if extra != extras.last {
                                            Text(",")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                    }
                }
            }

            // Footer
            HStack {
                Text("Total:")
                    .fontWeight(.medium)
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .fontWeight(.bold)
            }
            .padding(.top, 4)

            // Admin actions (if provided)
            if let adminActions = adminActions {
                Divider()
                adminActions()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .green
        case "Done", "Completed": return .gray
        default: return .gray
        }
    }
}
