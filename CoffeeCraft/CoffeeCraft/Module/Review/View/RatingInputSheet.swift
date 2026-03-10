//
//  RatingInputSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/10/26.
//

import SwiftUI

// MARK: - RatingInputSheet

struct RatingInputSheet: View {

    // MARK: Dependencies

    @ObservedObject var vm: ReviewViewModel

    let productName: String
    let imageURL:    String

    // MARK: Local state

    @Environment(\.dismiss) private var dismiss
    @FocusState private var bodyFocused: Bool

    // MARK: Constants

    private let maxBodyLength = 280
    private let warningThreshold = 260

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    productHeader
                    starSection
                    bodySection
                    submitButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPrimary)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)      // we draw our own handle
        .presentationBackground(Color.bgPrimary)
        .onDisappear {
            vm.resetDraft()
        }
    }
}

// MARK: - Drag Handle

private extension RatingInputSheet {

    var dragHandle: some View {
        Capsule()
            .fill(Color.borderColor.opacity(0.8))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Product Header

private extension RatingInputSheet {

    var productHeader: some View {
        HStack(spacing: 14) {
            AsyncImageCard(
                imageURL: imageURL,
                height:   56,
                width:    56,
                corner:   14
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.existingRating == nil ? "Rate your order" : "Edit your review")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Text(productName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            // Dismiss button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.surfaceSub)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Star Section

private extension RatingInputSheet {

    var starSection: some View {
        VStack(spacing: 12) {
            StarRatingView(
                mode: .interactive(rating: $vm.draftScore),
                size: 44
            )

            // Mood label — reacts to selected score
            if vm.draftScore > 0 {
                Text(moodLabel(for: vm.draftScore))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.accentPrimary)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.draftScore)
            } else {
                Text("Tap a star to rate")
                    .font(.subheadline)
                    .foregroundColor(.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    vm.draftScore > 0
                        ? Color.accentPrimary.opacity(0.25)
                        : Color.borderColor.opacity(0.5),
                    lineWidth: 1
                )
                .animation(.easeInOut(duration: 0.2), value: vm.draftScore)
        )
    }

    /// Returns an emoji + label based on the selected star score.
    func moodLabel(for score: Int) -> String {
        switch score {
        case 1: return "😞  Poor"
        case 2: return "😐  Fair"
        case 3: return "🙂  Good"
        case 4: return "😊  Great"
        case 5: return "🤩  Amazing!"
        default: return ""
        }
    }
}

// MARK: - Review Body Section

private extension RatingInputSheet {

    var bodySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your review")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.textPrimary)

                Text("(optional)")
                    .font(.caption)
                    .foregroundColor(.textMuted)

                Spacer()

                // Character counter
                characterCounter
            }

            ZStack(alignment: .topLeading) {
                // Placeholder
                if vm.draftBody.isEmpty && !bodyFocused {
                    Text("Share what you loved — or what could be better…")
                        .font(.subheadline)
                        .foregroundColor(.textMuted)
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $vm.draftBody)
                    .focused($bodyFocused)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100, maxHeight: 160)
                    .onChange(of: vm.draftBody) { _, newValue in
                        // Enforce character limit
                        if newValue.count > maxBodyLength {
                            vm.draftBody = String(newValue.prefix(maxBodyLength))
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        }
                    }
            }
            .padding(12)
            .background(Color.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        bodyFocused
                            ? Color.accentPrimary.opacity(0.5)
                            : Color.borderColor.opacity(0.5),
                        lineWidth: 1
                    )
                    .animation(.easeInOut(duration: 0.2), value: bodyFocused)
            )
        }
    }

    var characterCounter: some View {
        let remaining = maxBodyLength - vm.draftBody.count
        let isWarning = vm.draftBody.count >= warningThreshold

        return Text("\(remaining)")
            .font(.caption.monospacedDigit())
            .fontWeight(isWarning ? .semibold : .regular)
            .foregroundColor(
                isWarning
                    ? (remaining == 0 ? .errorRed : .warningAmber)
                    : .textMuted
            )
            .animation(.easeInOut(duration: 0.15), value: isWarning)
    }
}

// MARK: - Submit Button

private extension RatingInputSheet {

    var submitButton: some View {
        Button {
            bodyFocused = false
            Task { await vm.submitOrEdit() }
            // Dismiss after a brief delay so the user sees the loading state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !vm.isSubmitting {
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 8) {
                if vm.isSubmitting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: vm.existingRating == nil ? "star.bubble.fill" : "pencil.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(vm.submitButtonLabel)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if vm.isInputValid {
                        LinearGradient.brandPrimary
                    } else {
                        Color.textMuted.opacity(0.3)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: vm.isInputValid ? Color.accentPrimary.opacity(0.35) : .clear,
                radius: 8, x: 0, y: 4
            )
            .animation(.easeInOut(duration: 0.2), value: vm.isInputValid)
        }
        .disabled(!vm.isInputValid || vm.isSubmitting)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("New rating") {
    struct PreviewWrapper: View {
        @StateObject var vm = ReviewViewModel()
        @State var show = true

        var body: some View {
            Color.bgSecondary
                .ignoresSafeArea()
                .sheet(isPresented: $show) {
                    RatingInputSheet(
                        vm:          vm,
                        productName: "Caramel Macchiato",
                        imageURL:    "https://i.postimg.cc/VNK61H8p/capp.jpg"
                    )
                }
                .task {
                    // Simulate eligible, no existing rating
                    vm.proofOrderId = "order_001"
                }
        }
    }
    return PreviewWrapper()
}

#Preview("Edit existing") {
    struct PreviewWrapper: View {
        @StateObject var vm = ReviewViewModel()
        @State var show = true

        var body: some View {
            Color.bgSecondary
                .ignoresSafeArea()
                .sheet(isPresented: $show) {
                    RatingInputSheet(
                        vm:          vm,
                        productName: "Matcha Latte",
                        imageURL:    "https://i.postimg.cc/VNK61H8p/capp.jpg"
                    )
                }
                .task {
                    // Simulate existing rating
                    vm.draftScore = 4
                    vm.draftBody  = "Really smooth, not too sweet."
                }
        }
    }
    return PreviewWrapper()
}
