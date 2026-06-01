//
//  DateRangePickerSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 28/05/2026.
//

import SwiftUI

/// Reusable date range picker. Presets in the top section, custom From/To below.
struct DateRangePickerSheet: View {

    @Binding var range: DateRange
    var onApply: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var customStart: Date
    @State private var customEnd: Date

    init(range: Binding<DateRange>, onApply: (() -> Void)? = nil) {
        _range = range
        _customStart = State(initialValue: range.wrappedValue.start)
        _customEnd = State(initialValue: range.wrappedValue.end)
        self.onApply = onApply
    }

    private let presets: [DateRange] = [
        .last7Days,
        .last30Days,
        .last90Days,
        .thisMonth(),
        .lastMonth()
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick presets") {
                    ForEach(presets, id: \.presetLabel) { preset in
                        presetRow(preset)
                    }
                }

                Section("Custom range") {
                    DatePicker("From", selection: $customStart, in: ...customEnd,
                               displayedComponents: .date)
                    DatePicker("To", selection: $customEnd, in: customStart...,
                               displayedComponents: .date)

                    Button {
                        let cal = Calendar.current
                        let normalizedEnd = cal.date(bySettingHour: 23, minute: 59, second: 59,
                                                     of: customEnd) ?? customEnd
                        range = DateRange(
                            start: cal.startOfDay(for: customStart),
                            end: normalizedEnd,
                            presetLabel: nil
                        )
                        onApply?()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Apply custom range")
                        }
                        .foregroundStyle(Color.accentPrimary)
                    }
                }
            }
            .navigationTitle("Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func presetRow(_ preset: DateRange) -> some View {
        Button {
            range = preset
            onApply?()
            dismiss()
        } label: {
            HStack {
                Text(preset.presetLabel ?? "")
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                if range.presetLabel == preset.presetLabel {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentPrimary)
                }
            }
        }
    }
}
