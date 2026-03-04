//
//  TabBarView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/22/25.
//
import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        TabsLayoutView(selectedTab: $selectedTab)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 40, trailing: 16))
            .background(
                Color(UIColor.systemBackground)
                    .mask(
                        RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                    )
            )
            .frame(height: 70)
            .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: -5)
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
                            .font(.title3.weight(.semibold))
                            .foregroundColor(isSelected ? tab.color : .primary.opacity(0.6))
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
                                .font(.title3.weight(.semibold))
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

    case home       // Home / Featured
    case menu       // Coffee menu
    case orders     // Past orders
    case profile    // User profile

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .menu:
            return "list.bullet.rectangle.portrait.fill"
        case .orders:
            return "clock.fill"
        case .profile:
            return "person.crop.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .menu:
            return "Menu"
        case .orders:
            return "Orders"
        case .profile:
            return "Account"
        }
    }

    var color: Color {
        switch self {
        case .home:
            return .accentPrimary
        case .menu:
            return .accentPrimary
        case .orders:
            return .accentPrimary
        case .profile:
            return .accentPrimary
        }
    }
}
