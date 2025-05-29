//
//  Tab.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI

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