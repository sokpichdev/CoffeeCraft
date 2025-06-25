//
//  ViewHeightKey.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/25/25.
//
import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
