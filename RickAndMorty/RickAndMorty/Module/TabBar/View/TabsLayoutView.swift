//
//  TabsLayoutView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

struct TabsLayoutView: View {
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            ForEach(Tab.allCases) { tab in
                TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace)
                    .frame(width: 65, height: 65)
                Spacer(minLength: 0)
            }
        }
    }
    
    private struct TabButton: View {
        let tab: Tab
        @Binding var selectedTab: Tab
        var namespace: Namespace.ID
        
        private var isSelected: Bool {
            selectedTab == tab
        }
        
        var body: some View {
            Button {
                withAnimation {
                    selectedTab = tab
                }
            } label: {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(.ultraThickMaterial)
                            .background {
                                Circle()
                                    .stroke(lineWidth: 15)
                                    .fill(.ultraThinMaterial.opacity(0.5))
                            }
                            .offset(y: -40)
                            .matchedGeometryEffect(id: "Selected Tab", in: namespace)
                            .animation(.spring(), value: selectedTab)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? Color(.label) : Color(.secondaryLabel))
                        .scaleEffect(isSelected ? 1 : 0.8)
                        .offset(y: isSelected ? -40 : 0)
                        .animation(isSelected ? .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1) : .spring(), value: selectedTab)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
