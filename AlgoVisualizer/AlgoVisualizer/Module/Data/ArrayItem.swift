//
//  ArrayItem.swift
//  AlgoVisualizer
//
//  Created by Sok Pich on 5/2/25.
//

import SwiftUI

struct ArrayItem: Identifiable {
    let id = UUID()
    var value: Int
    var color: Color = .blue
}

enum SortControlState {
    case idle
    case running
    case paused
    case stepping
}
