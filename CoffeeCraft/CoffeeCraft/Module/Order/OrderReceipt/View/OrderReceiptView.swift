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
    
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var isExporting = false

    var body: some View {
        CustomNavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                CustomRefreshScrollView({
                    VStack(spacing: 0) {
                        HeaderSection(userName: userName, animated: true)
                        ReceiptPaper(order: order, userName: userName, animated: true)
                        FooterNote(animated: true)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                })
            }
            .customNavigationBar("") {
                ToolBarButton.back { dismiss() }
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("square.and.arrow.down")) {
                    exportPDF()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .overlay {
            if isExporting {
                ProgressView("Generating PDF...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - PDF Export
    private func exportPDF() {
        isExporting = true
        
        let exportContent = VStack(spacing: 0) {
            HeaderSection(userName: userName, animated: false)
            ReceiptPaper(order: order, userName: userName, animated: false)
            FooterNote(animated: false)
        }
        .frame(width: 380)
        .background(Color(.systemGroupedBackground))
        
        exportContent.exportToPDF(filename: "CoffeeCraft_Receipt_\(String(describing: order.orderId))") { url in
            isExporting = false
            if let url = url {
                pdfURL = url
                showShareSheet = true
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    let userName: String
    let animated: Bool
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Order Confirmed")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color.coffeeDarkBrown)
                Text("Your coffee is on its way ☕")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
        }
        .padding()
        .onAppear {
            if animated {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appeared = true
                }
            } else {
                appeared = true
            }
        }
    }
}

// MARK: - Receipt Paper
struct ReceiptPaper: View {
    let order: Order
    let userName: String
    let animated: Bool
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            TornEdge(position: .top)
            
            VStack(spacing: 0) {
                // Stamp
                VStack(spacing: 6) {
                    CoffeeStamp(animated: animated)
                    
                    Text("OFFICIAL RECEIPT")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color.coffeeDarkBrown.opacity(0.35))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                PerforatedDivider().padding(.vertical, 4)
                
                // Meta
                MetaSection(order: order, userName: userName)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                
                PerforatedDivider().padding(.vertical, 4)
                
                // Items
                ItemsSection(order: order, animated: animated)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                
                PerforatedDivider().padding(.vertical, 4)
                
                // Total
                TotalSection(order: order)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                
                // Barcode
                BarcodeStrip()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .background(Color.surfaceSub.opacity(0.35))
            
            TornEdge(position: .bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.surfaceSub.opacity(0.35))
        )
        .shadow(color: Color.coffeeDarkBrown.opacity(0.10), radius: 16, x: 0, y: 6)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                    appeared = true
                }
            } else {
                appeared = true
            }
        }
    }
}

// MARK: - Meta Section
struct MetaSection: View {
    let order: Order
    let userName: String
    
    var body: some View {
        VStack(spacing: 10) {
            MetaRow(label: "ORDER", value: "#\(order.orderId ?? 0)", mono: true)
            if let dateTime = order.timestamp {
                MetaRow(label: "DATE", value: dateTime.formatted(.dateTime.month(.abbreviated).day().year()))
                MetaRow(label: "TIME", value: dateTime.formatted(.dateTime.hour().minute()))
            }
            MetaRow(label: "CUSTOMER", value: userName)
        }
    }
}

struct MetaRow: View {
    let label: String
    let value: String
    var mono: Bool = false
    
    var body: some View {
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
}

// MARK: - Items Section
struct ItemsSection: View {
    let order: Order
    let animated: Bool
    
    // Unwrap the optional array and strip nil elements in one step
    private var items: [CartItemData] {
        (order.items ?? []).compactMap { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ITEMS")
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .tracking(3)
                .foregroundColor(Color.coffeeDarkBrown.opacity(0.4))
            
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                ReceiptItemRow(
                    item: item,
                    animationDelay: animated ? Double(index) * 0.08 + 0.4 : 0,
                    animated: animated
                )
                
                if index < items.count - 1 {
                    Rectangle()
                        .fill(Color.coffeeDarkBrown.opacity(0.07))
                        .frame(height: 1)
                }
            }
        }
    }
}

// MARK: - Total Section
struct TotalSection: View {
    let order: Order
    
    var body: some View {
        HStack {
            Text("TOTAL")
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .tracking(2)
            Spacer()
            Text("$\(order.totalPrice ?? 0.0, specifier: "%.2f")")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
        }
        .foregroundColor(Color.coffeeDarkBrown)
    }
}

// MARK: - Barcode
struct BarcodeStrip: View {
    var body: some View {
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
}

// MARK: - Footer
struct FooterNote: View {
    let animated: Bool
    
    @State private var appeared = false
    
    var body: some View {
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
        .opacity(appeared ? 1 : 0)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                    appeared = true
                }
            } else {
                appeared = true
            }
        }
    }
}
