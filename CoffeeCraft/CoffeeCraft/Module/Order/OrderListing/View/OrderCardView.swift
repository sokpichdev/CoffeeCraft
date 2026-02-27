//
//  OrderCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 25/02/2026.
//
import SwiftUI

struct OrderCardView: View {
    let order: Order
    var adminActions: (() -> AnyView)? = nil
    var onNavigate: (() -> Void)? = nil
    
    @State private var isExpanded: Bool = false
    
    // Pre-compute values to avoid recalculation during body
    private let itemCount: Int
    private let formattedOrderNumber: String
    private let statusColorValue: Color
    private let statusIcon: String
    
    init(order: Order, adminActions: (() -> AnyView)? = nil, onNavigate: (() -> Void)? = nil) {
        self.order = order
        self.adminActions = adminActions
        self.onNavigate = onNavigate
        
        // Pre-compute expensive operations
        self.itemCount = order.items.count
        self.formattedOrderNumber = String(format: "%04d", order.orderId)
        self.statusColorValue = OrderCardView.computeStatusColor(order.status)
        self.statusIcon = OrderCardView.computeStatusIcon(order.status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            itemsPreviewSection
            if isExpanded {
                detailedItemsSection
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
            
            Divider().padding(.horizontal)
            footerSection
            
            if adminActions != nil {
                Divider()
                    .padding(.horizontal)
                adminActions?()
                    .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                
                Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StatusBadge(status: order.status)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    statusColorValue.opacity(0.15),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var itemsPreviewSection: some View {
        HStack(spacing: 12) {
            // Leftmost (index 0) is behind, rightmost is in front
            ZStack(alignment: .leading) {
                ForEach(Array(order.items.prefix(3).enumerated()), id: \.offset) { index, item in
                    CachedThumbnail(url: item.imageURL)
                        .offset(x: CGFloat(index * 20))
                        .zIndex(Double(index))
                }
                
                if itemCount > 3 {
                    Text("+\(itemCount - 3)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.coffeeBrown))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: CGFloat(min(itemCount, 3)) * 20)
                        .zIndex(3) // Highest zIndex to appear on top of all
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
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
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .foregroundColor(.coffeeBrown)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.coffeeBrown.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    private var detailedItemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(order.items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 12) {
                    CachedThumbnail(url: item.imageURL, size: 44, cornerRadius: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        if let selections = item.selections, !selections.isEmpty {
                            Text(selections.map { $0.value }.joined(separator: " • "))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        if let extras = item.extras, !extras.isEmpty {
                            Text(extras.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundColor(.coffeeBrown.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if index < order.items.count - 1 {
                    Divider().padding(.horizontal)
                }
            }
        }
        .background(Color.gray.opacity(0.03))
    }
    
    private var footerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Amount")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("$\(order.totalPrice, specifier: "%.2f")")
                    .font(.title3).fontWeight(.bold).fontDesign(.rounded)
                    .foregroundColor(.coffeeBrown)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(.coffeeBrown)
        }
        .padding()
    }
    
    // MARK: - Static Methods (avoid recreating closures)
    private static func computeStatusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .coffeeOliveGreen
        case "Done", "Completed": return .coffeeBrown
        default: return .coffeeBrown
        }
    }
    
    private static func computeStatusIcon(_ status: String) -> String {
        switch status {
        case "Pending": return "clock.fill"
        case "In Progress", "InProgress": return "hammer.fill"
        case "Ready": return "bell.fill"
        case "Done", "Completed": return "checkmark.circle.fill"
        default: return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Optimized Thumbnail Component
struct CachedThumbnail: View {
    let url: String
    var size: CGFloat = 32
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        AsyncImageCard(
            imageURL: url,
            isFill: true,
            height: size,
            width: size,
            corner: cornerRadius
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        // Prevent image loading from blocking main thread
        .id(url)
    }
}
