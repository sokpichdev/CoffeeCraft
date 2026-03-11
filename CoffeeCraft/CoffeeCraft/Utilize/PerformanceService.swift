//
//  PerformanceService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  A typed wrapper around Firebase Performance Monitoring.
//  Traces are no-ops in Dev so local runs don't pollute the dashboard.
//  Active from SIT upward.
//
//  USAGE:
//
//    let result = try await PerformanceService.shared.trace(.menuFetch) {
//        try await repository.fetchAll()
//    }
//
//  ADDING A NEW TRACE:
//    1. Add a case to TraceName.
//    2. Wrap the async work at its call site.
//

import FirebasePerformance
import Foundation

final class PerformanceService {

    static let shared = PerformanceService()
    private init() {}

    // MARK: - Trace Names
    //
    // Raw values appear as-is in the Firebase console under Performance > Traces.
    // Use snake_case — Firebase treats them as-is, no transformation is applied.

    enum TraceName: String {
        case menuFetch = "menu_fetch"
        case orderPlacement = "order_placement"
        case authLogin = "auth_login"
        case walletTopUp = "wallet_top_up"
    }

    // MARK: - Public API

    /// Wraps an async throwing operation in a named Firebase Performance trace.
    /// The trace starts immediately, stops when the block returns (or throws).
    ///
    /// No-ops in the Dev environment — the block still executes normally,
    /// but no trace is sent to Firebase.
    ///
    /// - Parameters:
    ///   - name: The trace name as it will appear in the Firebase console.
    ///   - block: The async work to measure.
    /// - Returns: Whatever the block returns.
    /// - Throws: Re-throws any error from the block (trace is still stopped on throw).
    @discardableResult
    func trace<T>(_ name: TraceName, block: () async throws -> T) async rethrows -> T {
        guard Constants.currentEnv != .dev else {
            return try await block()
        }
        let trace = Performance.startTrace(name: name.rawValue)
        defer {
            trace?.stop()
            AppLog.firestore.debug("⏱️ Performance trace stopped — \(name.rawValue)")
        }
        AppLog.firestore.debug("⏱️ Performance trace started — \(name.rawValue)")
        return try await block()
    }
}
