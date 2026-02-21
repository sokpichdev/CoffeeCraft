//
//  InboxFilter.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/15/26.
//
import SwiftUI

enum InboxFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case read = "Read"

    var id: String { rawValue }
}


