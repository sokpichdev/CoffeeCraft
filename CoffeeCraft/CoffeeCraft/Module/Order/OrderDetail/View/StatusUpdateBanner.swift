//
//  StatusUpdateBanner.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct StatusUpdateBanner: View {
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Status Updated!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Order is now \(statusDisplayName(status))")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [statusColor(status), statusColor(status).opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .shadow(color: statusColor(status).opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    func statusDisplayName(_ status: String) -> String {
        switch status {
        case "InProgress": return "In Progress"
        case "Completed": return "Completed"
        default: return status
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "Pending": return .orange
        case "In Progress", "InProgress": return .blue
        case "Ready": return .green
        case "Done", "Completed": return .gray
        default: return .brown
        }
    }
}
