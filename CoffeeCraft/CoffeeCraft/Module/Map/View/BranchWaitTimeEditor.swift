//
//  BranchWaitTimeEditor.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/6/26.
//


//
//  BranchWaitTimeEditor.swift
//  CoffeeCraft
//
//  Map Module — Phase 6
//  Admin-only sheet for updating a branch's estimated wait time.
//  Shown from AdminOrdersView via a long-press or dedicated button.
//  Only managers can write estimatedWaitMinutes (enforced by Firestore rules).
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
            VStack(spacing: 24) {

                // Branch name header
                VStack(spacing: 4) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.accentPrimary)
                    Text(branch.name)
                        .font(.custom("Nunito-Bold", size: 18))
                        .foregroundStyle(.textPrimary)
                    Text("Set estimated wait time for customers")
                        .font(.custom("Nunito-Regular", size: 13))
                        .foregroundStyle(.textMuted)
                }
                .padding(.top, 8)

                // Wait time picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wait Time")
                        .font(.custom("Nunito-Bold", size: 14))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(options, id: \.self) { mins in
                            WaitOption(
                                minutes: mins,
                                isSelected: selectedMinutes == mins
                            ) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.25)) {
                                    selectedMinutes = mins
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Error message
                if let err = saveError {
                    Text(err)
                        .font(.custom("Nunito-Regular", size: 13))
                        .foregroundStyle(.semanticError)
                        .padding(.horizontal, 20)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
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
                            }
                            Text(isSaving ? "Saving…" : "Save Wait Time")
                                .font(.custom("Nunito-Bold", size: 16))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.accentPrimary)
                        .cornerRadius(14)
                    }
                    .disabled(isSaving)

                    Button {
                        saveWaitTime(minutes: nil)
                    } label: {
                        Text("Clear Wait Time")
                            .font(.custom("Nunito-SemiBold", size: 14))
                            .foregroundStyle(.textMuted)
                    }
                    .disabled(isSaving || branch.estimatedWaitMinutes == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
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
        isSaving  = true
        saveError = nil
        Task {
            do {
                try await BranchRepository.shared.update(
                    branchId: branchId,
                    waitMinutes: minutes
                )
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                await MainActor.run { dismiss() }
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                await MainActor.run {
                    saveError = error.localizedDescription
                    isSaving  = false
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

    var label: String {
        minutes == 0 ? "No wait" : "\(minutes) min"
    }

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.custom(isSelected ? "Nunito-Bold" : "Nunito-Regular", size: 13))
                .foregroundStyle(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.accentPrimary : Color.surfaceSub)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color.clear : Color.border,
                            lineWidth: 0.8
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(isSelected ? "selected" : "not selected")")
    }
}
