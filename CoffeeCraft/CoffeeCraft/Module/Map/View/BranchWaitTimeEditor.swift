//
//  BranchWaitTimeEditor.swift
//  CoffeeCraft
//
//  Map Module — UI Enhanced
//  Checkmark on selected tile, richer header, cleaner action area.
//

import SwiftUI

// MARK: - BranchWaitTimeEditor

struct BranchWaitTimeEditor: View {

    let branch: Branch
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMinutes: Int
    @State private var isSaving = false
    @State private var saveError: String?

    private let options = [0, 5, 10, 15, 20, 30, 45, 60]

    init(branch: Branch) {
        self.branch = branch
        _selectedMinutes = State(initialValue: branch.estimatedWaitMinutes ?? 0)
    }

    var body: some View {
        CustomNavigationStack {
            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────────────
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.accentPrimary.opacity(0.12))
                            .frame(width: 60, height: 60)
                        Image(systemName: "clock.badge.fill")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(Color.accentPrimary)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.top, 12)

                    Text(branch.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textPrimary)

                    Text("Set estimated wait time for customers")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

                // ── Section label ───────────────────────────────────
                HStack {
                    Text("Estimated Wait")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                // ── Wait grid ───────────────────────────────────────
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                    spacing: 10
                ) {
                    ForEach(options, id: \.self) { mins in
                        WaitOption(
                            minutes: mins,
                            isSelected: selectedMinutes == mins
                        ) {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                                selectedMinutes = mins
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // ── Error ───────────────────────────────────────────
                if let err = saveError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text(err)
                            .font(.system(size: 13, weight: .regular))
                    }
                    .foregroundColor(Color.semanticError)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }

                Spacer()

                // ── Actions ─────────────────────────────────────────
                VStack(spacing: 10) {
                    // Save button
                    Button {
                        saveWaitTime(minutes: selectedMinutes)
                    } label: {
                        HStack(spacing: 8) {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.85)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .symbolRenderingMode(.hierarchical)
                            }
                            Text(isSaving ? "Saving…" : "Save Wait Time")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.accentPrimary)
                                .shadow(color: Color.accentPrimary.opacity(0.4), radius: 12, x: 0, y: 5)
                        }
                    }
                    .buttonStyle(BounceButtonStyle())
                    .disabled(isSaving)

                    // Clear button — secondary, muted
                    Button {
                        saveWaitTime(minutes: nil)
                    } label: {
                        Text("Clear Wait Time")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.textMuted)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(BounceButtonStyle())
                    .disabled(isSaving || branch.estimatedWaitMinutes == nil)
                    .opacity((isSaving || branch.estimatedWaitMinutes == nil) ? 0.4 : 1)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color.bgPrimary)
            .customNavigationBar("Wait Time") {
                ToolBarButton(placement: .topBarTrailing, buttonType: .icon("xmark")) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Save

    private func saveWaitTime(minutes: Int?) {
        guard let branchId = branch.id else { return }
        isSaving = true
        saveError = nil
        Task {
            do {
                try await BranchRepository.shared.update(branchId: branchId, waitMinutes: minutes)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                await MainActor.run { dismiss() }
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                await MainActor.run {
                    saveError = error.localizedDescription
                    isSaving = false
                }
            }
        }
    }
}

// MARK: - WaitOption

private struct WaitOption: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var label: String { minutes == 0 ? "No wait" : "\(minutes) min" }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }

                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color.textPrimary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isSelected ? Color.accentPrimary : Color.surfaceSub)
                    .overlay {
                        if !isSelected {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(Color.borderColor.opacity(0.5), lineWidth: 0.5)
                        }
                    }
                    .shadow(
                        color: isSelected ? Color.accentPrimary.opacity(0.35) : .clear,
                        radius: 8, x: 0, y: 3
                    )
            }
        }
        .buttonStyle(BounceButtonStyle())
        .accessibilityLabel("\(label), \(isSelected ? "selected" : "not selected")")
    }
}
