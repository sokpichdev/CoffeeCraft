//
//  AppLog.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/20/26.
//

import OSLog
import Firebase

// MARK: - AppLog
// A centralized, reusable logging utility for CoffeeCraft.
// Built on Apple's OSLog framework for structured, filterable console output.
//
// FEATURES:
// - Categorized loggers (Auth, Menu, Order, etc.) for easy filtering in Xcode console
// - Automatically formats any Swift model as clean JSON
// - Handles Firebase-specific types: @DocumentID, Timestamp
// - Handles plain Swift types: String, Date, Optional
//
// HOW TO USE:
//   List:   AppLog.printList(fetchedItems, label: "Menu Items", logger: AppLog.menu)
//   Single: AppLog.printItem(user, label: "User Profile", logger: AppLog.profile)
//   Basic:  AppLog.auth.debug("✅ Signed in: \(email)")
//           AppLog.order.error("❌ Failed to place order: \(error.localizedDescription)")
//
// LOG LEVELS:
//   .debug()   → Development details, stripped automatically in release builds
//   .info()    → General flow info
//   .warning() → Unexpected but non-fatal (e.g. empty list, nil item)
//   .error()   → Failures and caught errors
//
// FILTER TIPS (Xcode console search bar):
//   Type "Auth"      → show only auth logs
//   Type "Menu"      → show only menu logs
//   Type "Order"     → show only order logs
//   Type "❌"        → show only errors across all categories

struct AppLog {
    
    // The app's unique identifier used to group logs in Console.app
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.sokpich.CoffeeCraft.dev"

    // MARK: - Loggers
    // Use the matching logger for each feature so logs are easy to filter
    static let auth      = Logger(subsystem: subsystem, category: "Auth")       // Sign in, sign up, sign out
    static let firestore = Logger(subsystem: subsystem, category: "Firestore")  // General Firestore calls
    static let profile   = Logger(subsystem: subsystem, category: "Profile")    // User profile data
    static let menu      = Logger(subsystem: subsystem, category: "Menu")       // Coffee menu items
    static let order     = Logger(subsystem: subsystem, category: "Order")      // User orders

    // MARK: - extractValue
    // Recursively walks through any Swift value using Mirror (Swift's reflection API)
    // and converts it into a JSON-serializable format.
    //
    // Handles these cases:
    //   Optional        → unwraps the value, or returns "null" if nil
    //   Date            → formats to readable string e.g. "Jan 1, 2025 at 8:00 AM"
    //   Timestamp       → converts Firebase Timestamp to Date, then formats it
    //   @DocumentID     → unwraps the property wrapper to get the raw String value
    //   Struct / Class  → recursively extracts all properties into a [String: Any] dict
    //   Everything else → returned as-is (String, Int, Bool, etc.)
    private static func extractValue(_ value: Any) -> Any {
        let mirror = Mirror(reflecting: value)

        // Unwrap Optional — if nil, return the string "null" for JSON display
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                return extractValue(child.value)
            }
            return "null"
        }

        // Convert Swift Date to a readable formatted string
        if let date = value as? Date {
            return date.formatted(date: .abbreviated, time: .shortened)
        }

        // Convert Firebase Timestamp → Date → readable formatted string
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue().formatted(date: .abbreviated, time: .shortened)
        }

        // Unwrap @DocumentID property wrapper
        // @DocumentID wraps the value in a struct with a single child labeled "value"
        // We strip this wrapper to get the raw String id
        if mirror.displayStyle == .struct,
           mirror.children.count == 1,
           let child = mirror.children.first,
           child.label == "value" {
            return extractValue(child.value)
        }

        // Handle structs and classes — recursively extract each property
        // @DocumentID properties are stored with a leading underscore (e.g. "_id")
        // so we strip it to get the clean key name (e.g. "id")
        if mirror.displayStyle == .struct || mirror.displayStyle == .class {
            var dict: [String: Any] = [:]
            for child in mirror.children {
                if let label = child.label {
                    let key = label.hasPrefix("_") ? String(label.dropFirst()) : label
                    dict[key] = extractValue(child.value)
                }
            }
            return dict
        }

        // Primitives (String, Int, Bool, Double, etc.) — return as-is
        return value
    }

    // MARK: - toJSON
    // Converts any Swift model into a pretty-printed JSON string.
    // Uses extractValue() to handle Firebase types before serialization.
    // Falls back to String(describing:) if JSON serialization fails.
    private static func toJSON<T>(_ item: T) -> String {
        let extracted = extractValue(item)
        guard let dict = extracted as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              let json = String(data: data, encoding: .utf8) else {
            return String(describing: item) // fallback for non-serializable types
        }
        return json
    }

    // MARK: - printList
    // Logs a list of any model as formatted JSON entries.
    // Shows count, index, and each item as clean JSON.
    // Shows a warning if the list is empty.
    //
    // Usage:
    //   AppLog.printList(fetchedAnnouncements, label: "Announcements", logger: AppLog.menu)
    //   AppLog.printList(fetchedOrders, label: "Orders", logger: AppLog.order)
    static func printList<T>(_ items: [T], label: String, logger: Logger = AppLog.firestore) {
        if items.isEmpty {
            logger.warning("⚠️ \(label): No items found")
            return
        }
        logger.debug("✅ \(label): \(items.count) item(s) fetched")
        items.enumerated().forEach { index, item in
            logger.debug("""
                ─── \(label) [\(index + 1)/\(items.count)] ───
                \(toJSON(item))
                """)
        }
    }

    // MARK: - printItem
    // Logs a single model as formatted JSON.
    // Shows a warning if the item is nil.
    //
    // Usage:
    //   AppLog.printItem(user, label: "User Profile", logger: AppLog.profile)
    //   AppLog.printItem(order, label: "Order Detail", logger: AppLog.order)
    static func printItem<T>(_ item: T?, label: String, logger: Logger = AppLog.firestore) {
        guard let item = item else {
            logger.warning("⚠️ \(label): Item is nil")
            return
        }
        logger.debug("""
            ✅ \(label):
            \(toJSON(item))
            """)
    }
}
