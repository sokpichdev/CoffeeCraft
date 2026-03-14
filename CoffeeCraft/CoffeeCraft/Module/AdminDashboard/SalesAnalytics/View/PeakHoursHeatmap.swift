//
//  PeakHoursHeatmap.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct PeakHoursHeatmap: View {

    let points: [PeakHourPoint]
    let maxCount: Int

    private let hours = stride(from: 6, through: 22, by: 2).map { $0 }
    private let weekdays = [1, 2, 3, 4, 5, 6, 7]

    private func count(weekday: Int, hour: Int) -> Int {
        points.first { $0.weekday == weekday && $0.hour == hour }?.orderCount ?? 0
    }

    private func cellColor(for count: Int) -> Color {
        guard maxCount > 0 else { return Color.accentPrimary.opacity(0.05) }
        let intensity = Double(count) / Double(maxCount)
        return Color.accentPrimary.opacity(max(0.05, intensity * 0.85))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("").frame(width: 34)
                ForEach(hours, id: \.self) { hour in
                    let label = hour == 12 ? "12p" : hour < 12 ? "\(hour)a" : "\(hour - 12)p"
                    Text(label)
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            ForEach(weekdays, id: \.self) { weekday in
                HStack(spacing: 2) {
                    Text(weekdayLabel(weekday))
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 32, alignment: .trailing)

                    ForEach(hours, id: \.self) { hour in
                        let count = count(weekday: weekday, hour: hour)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(cellColor(for: count))
                            .frame(maxWidth: .infinity)
                            .frame(height: 22)
                            .overlay(
                                count > 0 ?
                                Text("\(count)")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(count > maxCount / 2 ? .white : Color.textPrimary)
                                : nil
                            )
                    }
                }
                .padding(.vertical, 1)
            }

            // Legend
            HStack(spacing: 6) {
                Text("Low").font(.caption2).foregroundStyle(Color.textMuted)
                LinearGradient(
                    colors: [Color.accentPrimary.opacity(0.05), Color.accentPrimary.opacity(0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 60, height: 8)
                .clipShape(Capsule())
                Text("High").font(.caption2).foregroundStyle(Color.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 8)
        }
    }

    private func weekdayLabel(_ weekday: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][weekday - 1]
    }
}
