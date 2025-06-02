//
//  ScrollOffsetPreferenceKey.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/31/25.
//
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
