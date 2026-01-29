//
//  MinimumLoadingTime.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/29/26.
//
import Foundation

struct MinimumLoadingTime {
    private let start = Date()
    let duration: TimeInterval

    init(_ duration: TimeInterval) {
        self.duration = duration
    }

    func waitIfNeeded() async throws {
        let elapsed = Date().timeIntervalSince(start)
        if elapsed < duration {
            try await Task.sleep(
                nanoseconds: UInt64((duration - elapsed) * 1_000_000_000)
            )
        }
    }
}
