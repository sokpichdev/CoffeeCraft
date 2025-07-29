//
//  TabBarView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//

import SwiftUI

final class TabBarVisibilityManager: ObservableObject {
    @Published var isVisible: Bool = true
}

struct TabBarView: View {
    @Binding var selectedTab: Tab
    let bgColor: Color = .init(white: 0.9)

    var body: some View {
        TabsLayoutView(selectedTab: $selectedTab)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 40, trailing: 16))
            .background(
                Color.white
                        .mask(
                            RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        )
            )
            .frame(height: 70)
            .shadow(radius: 30)
    }
}

fileprivate struct TabsLayoutView: View {
    @Binding var selectedTab: Tab
    @Namespace var namespace
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases) { tab in
                TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace)
            }
        }
    }
    
    private struct TabButton: View {
        let tab: Tab
        @Binding var selectedTab: Tab
        var namespace: Namespace.ID
        @State private var selectedOffset: CGFloat = 0
        @State private var rotationAngle: CGFloat = 0
        
        var isSelected: Bool {
            selectedTab == tab
        }
        var body: some View {
            Button {
                withAnimation(.easeInOut) {
                    selectedTab = tab
                }
                selectedOffset = -60
                if tab < selectedTab {
                    rotationAngle += 360
                } else {
                    rotationAngle -= 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedOffset = 0
                    if tab < selectedTab {
                        rotationAngle += 720
                    } else {
                        rotationAngle -= 720
                    }
                }
            } label: {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(tab.color.opacity(0.2))
                            .matchedGeometryEffect(id: "Selected Tab", in: namespace)
                    }
                    HStack(spacing: 10) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelected ? tab.color : .black.opacity(0.6))
                            .rotationEffect(.degrees(rotationAngle))
                            .scaleEffect(isSelected ? 1 : 0.9)
                            .animation(.easeInOut, value: rotationAngle)
                            .opacity(isSelected ? 1 : 0.7)
                            .padding(.leading, isSelected ? 20 : 0)
                            .padding(.horizontal, selectedTab != tab ? 10 : 0)
                            .offset(y: selectedOffset)
                            .animation(.default, value: selectedOffset)
                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(tab.color)
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case home       // Hero Listing
    case ranking    // Hero Ranking
    case position   // Hero Lane Position
    case settings   // Settings

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .home:
            return "list.bullet.rectangle.portrait.fill" // Hero list
        case .ranking:
            return "chart.bar.fill"                      // Ranking chart
        case .position:
            return "map.fill"                            // Lane map
        case .settings:
            return "gearshape.fill"                      // Settings
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Heroes"
        case .ranking:
            return "Ranking"
        case .position:
            return "Position"
        case .settings:
            return "Settings"
        }
    }

    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .ranking:
            return .pink
        case .position:
            return .orange
        case .settings:
            return .teal
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
