//
//  StatusTimelineView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct StatusTimelineView: View {
    let status: String
    
    private let statuses = [
        ("Pending", "clock", "Order Received"),
        ("InProgress", "flame", "Preparing"),
        ("Ready", "cup.and.saucer.fill", "Ready for Pickup"),
        ("Completed", "checkmark.circle.fill", "Completed")
    ]
    
    var currentStatusIndex: Int {
        statuses.firstIndex { $0.0 == status } ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                ForEach(Array(statuses.enumerated()), id: \.offset) { index, item in
                    TimelineRow(
                        icon: item.1,
                        title: item.2,
                        subtitle: statusSubtitle(for: item.0, index: index),
                        isCompleted: index <= currentStatusIndex,
                        isCurrent: index == currentStatusIndex,
                        isLast: index == statuses.count - 1
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    func statusSubtitle(for statusCode: String, index: Int) -> String? {
        if index == currentStatusIndex {
            switch statusCode {
            case "Pending": return "Waiting to be prepared"
            case "InProgress": return "Barista is working on it"
            case "Ready": return "Come pick it up!"
            case "Completed": return "Enjoy your coffee!"
            default: return nil
            }
        }
        return nil
    }
}
