//
//  OrderDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/6/26.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    var isActive: Bool = false
    var body: some View {
        CustomRefreshScrollView( {
            VStack(alignment: .leading, spacing: 20) {
                // Order Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order #\(order.orderId)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(order.timestamp.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Status Badge
                    HStack {
                        Text("Status:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(order.status)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(statusColor(order.status).opacity(0.15))
                            .foregroundColor(statusColor(order.status))
                            .clipShape(Capsule())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // Order Items
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(order.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                            
                            // Selections
                            if let selections = item.selections, !selections.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(selections.keys.sorted(), id: \.self) { key in
                                        if let value = selections[key] {
                                            HStack {
                                                Text("• \(key):")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(value)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Extras
                            if let extras = item.extras, !extras.isEmpty {
                                HStack {
                                    Text("• Extras:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(extras.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if item.id != order.items.last?.id {
                                Divider()
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                
                // Total
                HStack {
                    Text("Total")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(order.totalPrice, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                
                // Status Timeline
                StatusTimelineView(status: order.status)
            }
            .padding()
        }, onRefresh: {
            
        })
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
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

// Status Timeline View
struct StatusTimelineView: View {
    let status: String
    
    private let statuses = ["Pending", "InProgress", "Ready", "Completed"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Progress")
                .font(.headline)
            
            VStack(spacing: 16) {
                ForEach(statuses, id: \.self) { step in
                    HStack(spacing: 12) {
                        // Circle indicator
                        ZStack {
                            Circle()
                                .fill(isCompleted(step) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 24, height: 24)
                            
                            if isCompleted(step) {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Status label
                        Text(step == "InProgress" ? "In Progress" : step)
                            .font(.subheadline)
                            .foregroundColor(isCompleted(step) ? .primary : .secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    func isCompleted(_ step: String) -> Bool {
        guard let currentIndex = statuses.firstIndex(of: status),
              let stepIndex = statuses.firstIndex(of: step) else {
            return false
        }
        return stepIndex <= currentIndex
    }
}
