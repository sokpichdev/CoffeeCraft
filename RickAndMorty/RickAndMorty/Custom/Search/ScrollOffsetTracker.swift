//
//  ScrollOffsetTracker.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/30/25.
//
import SwiftUI

class ScrollOffsetTracker: ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var isScrollingUp: Bool = true

    private var lastOffset: CGFloat = 0

    func updateOffset(_ newOffset: CGFloat) {
        isScrollingUp = newOffset < lastOffset
        lastOffset = newOffset
        offset = newOffset
    }
}
