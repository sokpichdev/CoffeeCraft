//
//  ContentView.swift
//  TabBar
//
//  Created by Sok Pich on 5/14/25.
//

import SwiftUI

let bgColor = Color.init(white: 0.92)

struct ContentView: View {
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            VStack(spacing: 70) {
                TabBarView1()
                TabBarView2()
                TabBarView3()
            }
            .padding(.horizontal)
        }
    }
}

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    case home, game, apps, movie
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .game:
            return "gamecontroller.fill"
        case .apps:
            return "square.stack.3d.up.fill"
        case .movie:
            return "play.tv.fill"
        }
    }
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .game:
            return "Games"
        case .apps:
            return "Apps"
        case .movie:
            return "Movies"
        }
    }
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .game:
            return .pink
        case .apps:
            return .orange
        case .movie:
            return .teal
        }
    }
}

#Preview {
    ContentView()
}
