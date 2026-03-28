//
//  CustomSegmentedControl.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/9/26.
//
import SwiftUI

// Protocol — any enum with a display title can drive the control
protocol SegmentItem: Hashable {
    var title: String { get }
}

// Existing Segment enum — unchanged, just add conformance
extension Segment: SegmentItem {} // title already returns rawValue

// Conform all dashboard enums
extension SalesPeriod: SegmentItem {
    var title: String { rawValue } // "7 Days" / "30 Days"
}
extension OrderAnalyticsSection: SegmentItem {
    var title: String { rawValue } // "Queue" / "History" / "Funnel"
}
extension ReviewDashboardSection: SegmentItem {
    var title: String { rawValue } // "Reviews" / "Analytics"
}

// Generic control — replaces the Segment-specific version
struct CustomSegmentedControl<T: SegmentItem>: View {
    @Binding var selectedSegment: T
    var segments: [T]
    var onClick: () -> Void

    @Namespace private var animation
    private let height: CGFloat = 38

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                Button(action: {
                    guard selectedSegment != segment else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedSegment = segment
                    }
                    onClick()
                }, label: {
                    ZStack {
                        if selectedSegment == segment {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .matchedGeometryEffect(id: "SEGMENT_BG", in: animation)
                                .frame(height: height)
                        }

                        Text(segment.title)
                            .font(.subheadline)
                            .fontWeight(selectedSegment == segment ? .semibold : .medium)
                            .foregroundColor(selectedSegment == segment ? .white : Color.accentPrimary)
                    }
                    .frame(maxWidth: .infinity, minHeight: height)
                    .contentShape(Rectangle())
                })
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedSegment == segment ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.bgPrimary)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.borderColor, lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }
}

enum Segment: String, CaseIterable {
    // order
    case activeOrders = "Active Orders"
    case myOrders = "My Orders"
    
    // dashboard
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    var title: String {
            rawValue
        }
}
