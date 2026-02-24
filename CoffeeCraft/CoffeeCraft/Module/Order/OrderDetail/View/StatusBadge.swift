//
//  StatusBadge.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor(status))
                .frame(width: 8, height: 8)
            
            Text(status == "InProgress" ? "In Progress" : status)
                .font(.footnote).fontWeight(.semibold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(statusColor(status).opacity(0.15))
        .foregroundColor(statusColor(status))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(statusColor(status).opacity(0.2), lineWidth: 1)
        )
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .coffeeOliveGreen
        case "Done", "Completed": return .brown
        default: return .brown
        }
    }
}
