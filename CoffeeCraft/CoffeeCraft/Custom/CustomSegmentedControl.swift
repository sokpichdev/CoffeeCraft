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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brown)
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
                            : Color.coffeeBrown
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
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.coffeeBrown.opacity(0.15))
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
