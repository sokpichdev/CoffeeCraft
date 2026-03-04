//
//  CustomSegmentedControl.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/9/26.
//
import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var selectedSegment: Segment
    var segments: [Segment] = Segment.allCases
    var onClick: () -> Void

    @Namespace private var animation

    private let height: CGFloat = 38

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                ZStack {
                    // Selected background
                    if selectedSegment == segment {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .matchedGeometryEffect(
                                id: "SEGMENT_BG",
                                in: animation
                            )
                            .frame(height: height)
                    }

                    Text(segment.title)
                        .font(.subheadline)
                        .fontWeight(selectedSegment == segment ? .semibold : .medium)
                        .foregroundColor(
                            selectedSegment == segment
                            ? .white
                            : Color.accentPrimary
                        )
                }
                .frame(maxWidth: .infinity, minHeight: height)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard selectedSegment != segment else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedSegment = segment
                    }
                    onClick()
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.75))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        )
    }
}

enum Segment: String, CaseIterable {
    case activeOrders = "Active Orders"
    case myOrders = "My Orders"
    
    var title: String {
            rawValue
        }
}
