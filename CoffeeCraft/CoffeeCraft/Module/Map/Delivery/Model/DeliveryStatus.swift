//
//  DeliveryStatus.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 15/03/2026.
//

import SwiftUI

// MARK: - DeliveryStatus

enum DeliveryStatus: String, Codable, CaseIterable {
    case orderPlaced
    case riderAssigned
    case pickedUp
    case enRoute
    case arriving
    case delivered

    // MARK: - Display

    var label: String {
        switch self {
        case .orderPlaced:   return "Preparing your order"
        case .riderAssigned: return "Rider heading to branch"
        case .pickedUp:      return "Rider picked up your order"
        case .enRoute:       return "On the way to you"
        case .arriving:      return "Almost there!"
        case .delivered:     return "Delivered!"
        }
    }

    var shortLabel: String {
        switch self {
        case .orderPlaced:   return "Placed"
        case .riderAssigned: return "Assigned"
        case .pickedUp:      return "Picked Up"
        case .enRoute:       return "En Route"
        case .arriving:      return "Arriving"
        case .delivered:     return "Delivered"
        }
    }

    var icon: String {
        switch self {
        case .orderPlaced:   return "cup.and.saucer.fill"
        case .riderAssigned: return "person.fill"
        case .pickedUp:      return "bag.fill"
        case .enRoute:       return "bicycle"
        case .arriving:      return "location.fill"
        case .delivered:     return "checkmark.seal.fill"
        }
    }

    // MARK: - Progress

    /// 0.0 – 1.0 fraction for the DeliveryStatusBar fill.
    var progressFraction: Double {
        let total = Double(DeliveryStatus.allCases.count - 1)
        let index = Double(DeliveryStatus.allCases.firstIndex(of: self) ?? 0)
        return index / total
    }

    /// Step index (0-based) used to drive the progress bar dots.
    var stepIndex: Int {
        DeliveryStatus.allCases.firstIndex(of: self) ?? 0
    }

    var isTerminal: Bool { self == .delivered }
}
