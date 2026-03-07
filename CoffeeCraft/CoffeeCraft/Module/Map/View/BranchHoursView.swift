//
//  BranchHoursView.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Cleaner row rhythm, refined today highlight with left accent bar.
//

import SwiftUI

// MARK: - BranchHoursView

struct BranchHoursView: View {

    let branch: Branch

    // MARK: - Day model

    private struct DaySchedule: Identifiable {
        let id = UUID()
        let day: String
        let shortDay: String
        let hours: String
        let isToday: Bool
    }

    private var schedule: [DaySchedule] {
        let days: [(String, String)] = [
            ("Monday", "Mon"), ("Tuesday", "Tue"), ("Wednesday", "Wed"),
            ("Thursday", "Thu"), ("Friday", "Fri"), ("Saturday", "Sat"), ("Sunday", "Sun")
        ]
        let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7

        return days.enumerated().map { index, pair in
            DaySchedule(
                day: pair.0,
                shortDay: pair.1,
                hours: branch.openingHours,
                isToday: index == todayIndex
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(schedule.enumerated()), id: \.element.id) { idx, entry in
                HStack(spacing: 12) {
                    // Today accent bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(entry.isToday ? Color.accentPrimary : Color.clear)
                        .frame(width: 3, height: 28)

                    // Day label
                    Text(entry.shortDay)
                        .font(.system(size: 13, weight: entry.isToday ? .bold : .regular, design: .rounded))
                        .foregroundColor(entry.isToday ? Color.accentPrimary : Color.textSecondary)
                        .frame(width: 30, alignment: .leading)

                    // Hours
                    Text(entry.hours)
                        .font(.system(size: 13, weight: entry.isToday ? .semibold : .regular))
                        .foregroundColor(entry.isToday ? Color.textPrimary : Color.textMuted)

                    Spacer()

                    // Today chip
                    if entry.isToday {
                        Text("Today")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.accentPrimary)
                            )
                    }
                }
                .padding(.vertical, 9)
                .padding(.trailing, 14)
                .background(
                    entry.isToday
                        ? Color.accentPrimary.opacity(0.06)
                        : Color.clear
                )

                if idx < schedule.count - 1 {
                    Divider()
                        .padding(.leading, 19)
                        .opacity(0.3)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.surfacePrimary)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
