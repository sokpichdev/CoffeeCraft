//
//  OrderCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 25/02/2026.
//
import SwiftUI

struct OrderCardView: View {
    let order: Order
    var adminActions: (() -> AnyView)?
    var onNavigate: (() -> Void)?
    var onReorder: (() -> Void)?
    
    /// Number of items to show in the preview stack before the +N badge
    private let previewDisplayCount: Int = 5
    
    @State private var isExpanded: Bool = false
    @Namespace private var animationNamespace
    
    // Pre-compute values to avoid recalculation during body
    private let formattedOrderNumber: String
    private let statusColorValue: Color
    private var items: [CartItemData] { (order.items ?? []).compactMap { $0 } }
    private var itemCount: Int { items.count }
    private var overflowCount: Int { max(0, items.count - previewDisplayCount) }
    
    private var isCompleted: Bool {
        let status = order.status?.lowercased() ?? ""
        return status == "completed" || status == "done"
    }

    init(order: Order, adminActions: (() -> AnyView)? = nil, onNavigate: (() -> Void)? = nil, onReorder: (() -> Void)? = nil) {
        self.order = order
        self.adminActions = adminActions
        self.onNavigate = onNavigate
        self.onReorder = onReorder
        self.formattedOrderNumber = String(format: "%04d", order.orderId ?? 0)
        self.statusColorValue = OrderCardView.computeStatusColor(order.status ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            itemsPreviewSection
            
            if isExpanded {
                detailedItemsSection
            }
            
            Divider().padding(.horizontal)
            footerSection
            
            if adminActions != nil {
                Divider().padding(.horizontal)
                adminActions?().padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.textPrimary.opacity(0.05), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onNavigate?()
        }
        // Prevent animation from affecting scroll performance
        .drawingGroup(opaque: false)
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order #\(formattedOrderNumber)")
                    .font(.callout)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .frame(height: 16)
                    .foregroundColor(.textPrimary)
                
                if let date = order.timestamp {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .frame(height: 12)
                }
            }
            
            Spacer()
            
            StatusBadge(status: order.status ?? "")
        }
        .padding()
        .background(
            LinearGradient(
                colors: [statusColorValue.opacity(0.2), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
    
    private var itemsPreviewSection: some View {
        HStack(spacing: 12) {
            // Stacked thumbnails area - shows either stack or expands into spacer
            ZStack(alignment: .leading) {
                if !isExpanded {
                    // Visible preview items (first N items)
                    ForEach(Array(items.prefix(previewDisplayCount).enumerated()), id: \.offset) { index, item in
                        FlyingThumbnail(
                            url: item.imageURL ?? "",
                            index: index,
                            namespace: animationNamespace,
                            isCircle: true
                        )
                        .offset(x: CGFloat(index * 20))
                        .zIndex(Double(index))
                    }
                    
                    // Overflow items stacked at badge position (invisible but for matched geometry)
                    if overflowCount > 0 {
                        let overflowItems = Array(items.dropFirst(previewDisplayCount).enumerated())
                        ForEach(overflowItems, id: \.offset) { index, item in
                            let actualIndex = index + previewDisplayCount
                            FlyingThumbnail(
                                url: item.imageURL ?? "",
                                index: actualIndex,
                                namespace: animationNamespace,
                                isCircle: true
                            )
                            .offset(
                                x: CGFloat(previewDisplayCount - 1) * 20, // Position at last visible item
                                y: CGFloat(index * 2) // Slight vertical offset to prevent z-fighting
                            )
                            .zIndex(Double(previewDisplayCount + index))
                            .opacity(0) // Invisible but participates in animation
                        }
                        
                        // Count badge on top
                        OverflowBadge(count: overflowCount)
                            .offset(x: CGFloat(previewDisplayCount - 1) * 20)
                            .zIndex(100)
                    }
                }
            }
            .opacity(isExpanded ? 0 : 1)
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isExpanded ? "Less" : "Details")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundColor(.accentPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.accentPrimary.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    private var detailedItemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                DetailItemRow(
                    item: item,
                    index: index,
                    isExpanded: isExpanded,
                    namespace: animationNamespace,
                    totalItems: itemCount
                )
            }
        }
        .background(Color.textMuted.opacity(0.03))
    }
    
    private var footerSection: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Amount")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Text("$\(order.totalPrice ?? 0.0, specifier: "%.2f")")
                    .font(.title3).fontWeight(.bold).fontDesign(.rounded)
                    .foregroundColor(.accentPrimary)
            }

            Spacer()

            if isCompleted {
                Button {
                    onReorder?()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .bold))
                        Text("Reorder")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.textPrimary).colorScheme(.dark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.semanticSuccess))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "chevron.right")
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(.accentPrimary.opacity(0.4))
            }
        }
        .padding()
    }
    
    private static func computeStatusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .semanticSuccess
        case "Done", "Completed": return .accentPrimary
        default: return .accentPrimary
        }
    }
}

// MARK: - Detail Item Row (all items use matched geometry)
struct DetailItemRow: View {
    let item: CartItemData
    let index: Int
    let isExpanded: Bool
    var namespace: Namespace.ID
    let totalItems: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // ALL items use matched geometry - same animation for everyone
            FlyingThumbnail(
                url: item.imageURL ?? "",
                index: index,
                namespace: namespace,
                size: 44,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if let qty = item.quantity, qty > 1 {
                        Text("×\(qty)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.accentGold)
                    }
                    Text(item.name ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(.textPrimary)
                }
                
                if let selections = item.selections, !selections.isEmpty {
                    Text(selections.map { $0.value }.joined(separator: " • "))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                if let extras = item.extras, !extras.isEmpty {
                    Text(extras.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundColor(.textMuted.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("$\(item.price ?? 0.0, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        
        if index < totalItems - 1 {
            Divider().padding(.horizontal)
        }
    }
}

// MARK: - Overflow Badge
struct OverflowBadge: View {
    let count: Int
    
    var body: some View {
        Text("+\(count)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(Circle().fill(Color.accentPrimary))
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}

// MARK: - Flying Thumbnail (unified for all items)
struct FlyingThumbnail: View {
    let url: String
    let index: Int
    var namespace: Namespace.ID
    
    var size: CGFloat = 32
    var cornerRadius: CGFloat = 16
    var isCircle: Bool = false
    private var geometryId: String { "thumbnail-\(url)-\(index)" }
    
    var body: some View {
        CachedThumbnail(url: url, size: size, cornerRadius: cornerRadius, isCircle: isCircle)
            .matchedGeometryEffect(
                id: geometryId,
                in: namespace,
                properties: .frame,
                anchor: .center,
                isSource: true
            )
    }
}

struct CachedThumbnail: View {
    let url: String
    var size: CGFloat = 32
    var cornerRadius: CGFloat = 16
    var isCircle: Bool = false
    
    var body: some View {
        AsyncImageCard(
            imageURL: url,
            isFill: true,
            height: size,
            width: size,
            corner: cornerRadius
        )
        .overlay(
            Group {
                if isCircle {
                    Circle().stroke(Color.white, lineWidth: 2)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.white, lineWidth: 2)
                }
            }
        )
        .clipShape(isCircle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: cornerRadius)))
        .id(url)
    }
}
