//
//  PointsProgressView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/30/26.
//
//  Shows progress toward the next 10-point loyalty milestone.
//

import SwiftUI

struct PointsProgressView: View {
    let currentPoints: Int

    private let milestone = 10
    private let rewardAmount = 20.0

    private var pointsInCurrentCycle: Int { currentPoints % milestone }
    private var progress: Double { Double(pointsInCurrentCycle) / Double(milestone) }
    private var nextMilestone: Int { (currentPoints / milestone + 1) * milestone }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                Label("Points Progress", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundColor(.accentPrimary)
                Spacer()
                Text("\(currentPoints) pts total")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentPrimary.opacity(0.12))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentPrimary, Color.accentGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 12)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 12)

            // Label row
            HStack {
                Text("\(pointsInCurrentCycle) / \(milestone) pts toward next reward")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("+\(rewardAmount.currencyFormatted) at \(nextMilestone) pts")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentPrimary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.surfacePrimary))
    }
}
