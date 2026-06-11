//
//  DateRangePickerSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 28/05/2026.
//

import SwiftUI

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
        VStack(spacing: 0) {
            dragHandle
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    presetsSection
                    Divider().background(Color.borderColor)
                    customRangeSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(26)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.bgPrimary)
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color.borderColor.opacity(0.8))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 16)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Date Range")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.accentPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.accentPrimary.opacity(0.08))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Quick Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick presets")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textMuted)
                .textCase(.uppercase)

            ChipFlowLayout(horizontalSpacing: 8, verticalSpacing: 10) {
                ForEach(presets, id: \.presetLabel) { preset in
                    let isSelected = range.presetLabel == preset.presetLabel
                    Button {
                        range = preset
                        onApply?()
                        dismiss()
                    } label: {
                        Text(preset.presetLabel ?? "")
                            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color.textPrimary : Color.accentPrimary)
                            .colorScheme(isSelected ? .dark : .light)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 18)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.accentPrimary : Color.accentPrimary.opacity(0.08))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.borderColor.opacity(isSelected ? 0 : 1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.18), value: range.presetLabel)
                }
            }
        }
    }

    // MARK: - Custom Range

    private var customRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom range")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textMuted)
                .textCase(.uppercase)

            HStack(spacing: 8) {
                dateCard(label: "From", date: $customStart, range: ...customEnd)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textMuted)

                dateCard(label: "To", date: $customEnd, range: customStart...)
            }

            applyButton
        }
    }

    private func dateCard(label: String, date: Binding<Date>, range: PartialRangeThrough<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.textMuted)
                .textCase(.uppercase)
            DatePicker("", selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .foregroundStyle(Color.textPrimary)
                .tint(Color.accentPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
        )
    }

    private func dateCard(label: String, date: Binding<Date>, range: PartialRangeFrom<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.textMuted)
                .textCase(.uppercase)
            DatePicker("", selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .foregroundStyle(Color.textPrimary)
                .tint(Color.accentPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
        )
    }

    private var applyButton: some View {
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
            Text("Apply Custom Range")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
