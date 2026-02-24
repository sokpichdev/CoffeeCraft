//
//  TimelineRow.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct TimelineRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isCompleted: Bool
    let isCurrent: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline indicator column
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    if isCompleted {
                        Image(systemName: isCurrent ? icon : "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    if isCurrent {
                        Circle()
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: 42, height: 42)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .regular))
                    .foregroundColor(isCompleted ? .primary : .secondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            
            Spacer()
        }
    }
}
