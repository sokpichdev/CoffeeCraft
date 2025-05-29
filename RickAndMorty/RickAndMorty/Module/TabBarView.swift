//
//  TabBarView.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

let bgColor = Color.init(white: 0.92)

struct TabBarView1: View {
    @State private var selectedTab: Tab = .characters
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .characters:
                    CharactersView()
                case .locations:
                    LocationsView()
                case .episodes:
                    EpisodesView()
                case .favorites:
                    FavoritesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                TabsLayoutView(selectedTab: $selectedTab, namespace: namespace)
            }
            .frame(height: 70)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    fileprivate struct TabsLayoutView: View {
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
                                .shadow(radius: 10)
                                .background {
                                    Circle()
                                        .stroke(lineWidth: 15)
                                        .foregroundColor(bgColor)
                                }
                                .offset(y: -40)
                                .matchedGeometryEffect(id: "Selected Tab", in: namespace)
                                .animation(.spring(), value: selectedTab)
                        }
                        Image(systemName: tab.icon)
                            .font(.system(size: 23, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelected ? .init(white: 0.9) : .gray)
                            .scaleEffect(isSelected ? 1 : 0.8)
                            .offset(y: isSelected ? -40 : 0)
                            .animation(isSelected ? .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1) : .spring(), value: selectedTab)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}


enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    case characters, locations, episodes, favorites
    
    var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .characters:
            return "person.3"
        case .locations:
            return "globe"
        case .episodes:
            return "tv"
        case .favorites:
            return "star"
        }
    }
    
    var title: String {
        switch self {
        case .characters:
            return "Characters"
        case .locations:
            return "Locations"
        case .episodes:
            return "Episodes"
        case .favorites:
            return "Favorites"
        }
    }
}

struct CharactersView: View {
    var body: some View {
        Text("Characters Screen")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
    }
}

struct LocationsView: View {
    var body: some View {
        Text("Locations Screen")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
    }
}

struct EpisodesView: View {
    var body: some View {
        Text("Episodes Screen")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
    }
}

struct FavoritesView: View {
    var body: some View {
        Text("Favorites Screen")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
    }
}
