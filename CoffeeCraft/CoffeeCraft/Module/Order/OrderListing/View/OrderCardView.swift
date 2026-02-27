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
    
    private var itemCount: Int { order.items.count }
    private var formattedOrderNumber: String { String(format: "%04d", order.orderId) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            itemsPreviewSection
            if isExpanded {
                detailedItemsSection
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
            
            Divider().padding(.horizontal)
            footerSection
            
            if let adminActions = adminActions {
                Divider()
                    .padding(.horizontal)
                adminActions()
                    .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle()) // Main tap navigates to detail
        .onTapGesture {
            onNavigate?()
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order #\(formattedOrderNumber)")
                    .font(.callout).fontWeight(.bold).fontDesign(.rounded)
                    .foregroundColor(.primary)
                
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
                    statusColor(order.status).opacity(0.15),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Items Preview Section
    private var itemsPreviewSection: some View {
        HStack(spacing: 12) {
            // Item Thumbnails Stack
            HStack(spacing: -8) {
                ForEach(Array(order.items.prefix(3).enumerated()), id: \.element.id) { index, item in
                    AsyncImageCard(imageURL: item.imageURL, isFill: true, height: 32, width: 32, corner: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(Circle())
                }
                
                if itemCount > 3 {
                    Text("+\(itemCount - 3)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.coffeeBrown)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
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
                .foregroundColor(.coffeeBrown)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.coffeeBrown.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    // MARK: - Detailed Items Section (Expandable)
    private var detailedItemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        AsyncImageCard(imageURL: item.imageURL, height: 44, width: 44, corner: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            // Selections
                            if let selections = item.selections, !selections.isEmpty {
                                Text(selections.map { "\($0.value)" }.joined(separator: " • "))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            // Extras
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
                            .foregroundColor(.primary)
                    }
                    
                    if index < order.items.count - 1 {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.03))
    }
    
    // MARK: - Footer Section
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
    
    // MARK: - Helper Methods
    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending":
            return .orange
        case "In Progress", "InProgress":
            return .blue
        case "Ready":
            return .coffeeOliveGreen
        case "Done", "Completed":
            return .coffeeBrown
        default:
            return .coffeeBrown
        }
    }
    
    func iconForStatus(_ status: String) -> String {
        switch status {
        case "Pending":
            return "clock.fill"
        case "In Progress", "InProgress":
            return "hammer.fill"
        case "Ready":
            return "bell.fill"
        case "Done", "Completed":
            return "checkmark.circle.fill"
        default:
            return "cup.and.saucer.fill"
        }
    }
}
