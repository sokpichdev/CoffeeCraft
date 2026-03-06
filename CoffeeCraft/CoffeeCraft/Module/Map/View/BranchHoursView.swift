//
//  BranchHoursView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 06/03/2026.
//  Map Module — Phase 3: Branch Selection + Routing
//

import SwiftUI

// MARK: - BranchHoursView

/// Displays a branch's weekly opening hours.
/// Today's row is highlighted with accentPrimary tint.
///
/// The Branch model stores `openingHours` as a plain string (e.g. "Mon–Sun  7:00 – 22:00").
/// This view parses `DaySchedule` entries so each day can be shown individually.
/// For mock data the same string covers all 7 days — Phase 6 can swap in a richer model.

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

    // MARK: - Build schedule from branch data

    private var schedule: [DaySchedule] {
        let days: [(String, String)] = [
            ("Monday", "Mon"),
            ("Tuesday", "Tue"),
            ("Wednesday", "Wed"),
            ("Thursday", "Thu"),
            ("Friday", "Fri"),
            ("Saturday", "Sat"),
            ("Sunday", "Sun")
        ]
        let todayIndex = (Calendar.current.component(.weekday, from: Date()) + 5) % 7

        return days.enumerated().map { index, pair in
            DaySchedule(
                day: pair.0,
                shortDay: pair.1,
                hours: branch.openingHours,   // Phase 6: per-day lookup
                isToday: index == todayIndex
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(schedule) { entry in
                HStack {
                    // Day label
                    Text(entry.shortDay)
                        .font(.custom(entry.isToday ? "Nunito-Bold" : "Nunito-Regular", size: 13))
                        .foregroundStyle(entry.isToday ? Color.accentPrimary : .textSecondary)
                        .frame(width: 36, alignment: .leading)

                    // Hours
                    Text(entry.hours)
                        .font(.custom(entry.isToday ? "Nunito-SemiBold" : "Nunito-Regular", size: 13))
                        .foregroundStyle(entry.isToday ? Color.textPrimary : .textMuted)

                    Spacer()

                    // Today badge
                    if entry.isToday {
                        Text("Today")
                            .font(.custom("Nunito-Bold", size: 10))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentPrimary)
                            .cornerRadius(6)
                    }
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(entry.isToday ? Color.accentPrimary.opacity(0.07) : Color.clear)

                if entry.shortDay != "Sun" {
                    Divider()
                        .padding(.leading, 12)
                        .opacity(0.4)
                }
            }
        }
        .background(Color.surfacePrimary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.border, lineWidth: 0.8)
        )
    }
}
//
//// MARK: - Preview
//
// #Preview {
//    BranchHoursView(branch: MockBranchData.all[0])
//        .padding()
//        .background(Color.bgPrimary)
// }
