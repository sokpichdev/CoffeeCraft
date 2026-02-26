//
//  OrderReceiptView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderReceiptView: View {
    let order: Order
    let userName: String
    @Environment(\.dismiss) private var dismiss

    @State private var headerAppeared = false
    @State private var receiptAppeared = false

    private var formattedOrderId: String {
        "#\(order.orderId)"
    }

    var body: some View {
        CustomNavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                CustomRefreshScrollView( {
                    VStack(spacing: 0) {
                        headerSection
                        receiptPaper
                        footerNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                })
            }
            .customNavigationBar("") {
                ToolBarButton.back {
                    dismiss()
                }
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Success check
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.coffeeOliveGreen.opacity(0.15), Color.coffeeOliveGreen.opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.coffeeOliveGreen)
                    .scaleEffect(headerAppeared ? 1 : 0.3)
                    .opacity(headerAppeared ? 1 : 0)
            }

            VStack(spacing: 4) {
                Text("Order Confirmed")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color.coffeeDarkBrown)

                Text("Your coffee is on its way ☕")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .opacity(headerAppeared ? 1 : 0)
            .offset(y: headerAppeared ? 0 : 8)
        }
        .padding(.top, 24)
        .padding(.bottom, 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                headerAppeared = true
            }
        }
    }

    // MARK: Receipt Paper

    private var receiptPaper: some View {
        VStack(spacing: 0) {
            // Top torn edge
            topTornEdge

            // Paper body
            VStack(spacing: 0) {
                paperContent
            }
            .background(Color.coffeeCream.opacity(0.35))

            // Bottom torn edge
            bottomTornEdge
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.coffeeCream.opacity(0.35))
        )
        .shadow(color: Color.coffeeDarkBrown.opacity(0.10), radius: 16, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .opacity(receiptAppeared ? 1 : 0)
        .offset(y: receiptAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                receiptAppeared = true
            }
        }
    }

    private var topTornEdge: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let segmentCount = 28
                let segW = w / CGFloat(segmentCount)
                path.move(to: CGPoint(x: 0, y: 10))
                for i in 0..<segmentCount {
                    let x = CGFloat(i) * segW
                    let peak: CGFloat = i % 2 == 0 ? 0 : 14
                    path.addLine(to: CGPoint(x: x + segW / 2, y: peak))
                    path.addLine(to: CGPoint(x: x + segW, y: 10))
                }
                path.addLine(to: CGPoint(x: w, y: 40))
                path.addLine(to: CGPoint(x: 0, y: 40))
                path.closeSubpath()
            }
            .fill(Color(.systemGroupedBackground))
        }
        .frame(height: 16)
    }

    private var bottomTornEdge: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let segmentCount = 28
                let segW = w / CGFloat(segmentCount)
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: 6))
                for i in stride(from: segmentCount, through: 0, by: -1) {
                    let x = CGFloat(i) * segW
                    let peak: CGFloat = i % 2 == 0 ? 16 : 2
                    path.addLine(to: CGPoint(x: x - segW / 2, y: peak))
                    path.addLine(to: CGPoint(x: x - segW, y: 6))
                }
                path.closeSubpath()
            }
            .fill(Color(.systemGroupedBackground))
        }
        .frame(height: 16)
    }

    private var paperContent: some View {
        VStack(spacing: 0) {
            // Brand stamp area
            VStack(spacing: 6) {
                CoffeeStamp()

                Text("OFFICIAL RECEIPT")
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(Color.coffeeDarkBrown.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            // Order meta
            PerforatedDivider()
                .padding(.vertical, 4)

            VStack(spacing: 10) {
                receiptMetaRow(label: "ORDER", value: formattedOrderId, mono: true)
                receiptMetaRow(label: "DATE", value: order.timestamp.formatted(.dateTime.month(.abbreviated).day().year()))
                receiptMetaRow(label: "TIME", value: order.timestamp.formatted(.dateTime.hour().minute()))
                receiptMetaRow(label: "CUSTOMER", value: userName)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            // Items
            PerforatedDivider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 14) {
                Text("ITEMS")
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))

                ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                    ReceiptItemRow(item: item, animationDelay: Double(index) * 0.08 + 0.4)

                    if index < order.items.count - 1 {
                        Rectangle()
                            .fill(Color.coffeeDarkBrown.opacity(0.07))
                            .frame(height: 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            // Total
            PerforatedDivider()
                .padding(.vertical, 4)

            HStack {
                Text("TOTAL")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(Color.coffeeDarkBrown)
                Spacer()
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.coffeeDarkBrown)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // Barcode-style decorative strip
            barcodeStrip
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }

    private func receiptMetaRow(label: String, value: String, mono: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(mono
                      ? .system(size: 13, weight: .semibold, design: .monospaced)
                      : .system(size: 13, weight: .medium))
                .foregroundColor(Color.coffeeDarkBrown)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var barcodeStrip: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(0..<60, id: \.self) { i in
                    let widths: [CGFloat] = [1, 2, 1, 3, 1, 2, 2, 1]
                    Rectangle()
                        .fill(Color.coffeeDarkBrown.opacity(i % 2 == 0 ? 0.6 : 0))
                        .frame(width: widths[i % widths.count])
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .frame(height: 40)
    }

    // MARK: Footer Note

    private var footerNote: some View {
        VStack(spacing: 6) {
            Text("Thank you for your order!")
                .font(.system(size: 13, design: .serif))
                .italic()
                .foregroundColor(.secondary)

            Text("Questions? Visit us at coffeecraft.app")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.secondary.opacity(0.6))
        }
        .padding(.top, 20)
        .opacity(receiptAppeared ? 1 : 0)
    }
}
