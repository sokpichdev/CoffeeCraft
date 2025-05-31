//
//  ScrollOffsetKey.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/30/25.
//
import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
