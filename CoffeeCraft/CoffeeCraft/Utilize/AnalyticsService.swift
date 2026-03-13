//
//  AnalyticsService.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/11/26.
//
//  A thin, testable wrapper around Firebase Analytics.
//  All calls go through AnalyticsService.shared.log(_:) — never call
//  Analytics.logEvent() directly from a ViewModel or View.
//
//  Events are silently dropped in Dev so local testing stays noise-free
//  in the Firebase console. Switch to .sit / .uat / .prod to see live data.
//
//  ADDING A NEW EVENT:
//    1. Add a case to AnalyticsEvent.
//    2. Add its (name, params) entry in analyticsPayload below.
//    3. Call AnalyticsService.shared.log(.yourEvent(...)) at the call site.
//

import Firebase
import FirebaseAnalytics
import Foundation

// MARK: - AnalyticsEvent

enum AnalyticsEvent {

    // Auth
    case login(method: String) // method = "email"
    case signup
    case logout

    // Menu & discovery
    case viewProduct(id: String, name: String, category: String)
    case viewMenu(category: String)
    case search(query: String, resultCount: Int)

    // Cart
    case addToCart(id: String, name: String, price: Double, category: String)
    case removeFromCart(id: String, name: String)

    // Checkout & orders
    case beginCheckout(total: Double, itemCount: Int, paymentMethod: String)
    case purchase(orderId: String, total: Double, paymentMethod: String)

    // Wallet
    case topUpWallet(amount: Double, method: String)

    // MARK: - Payload mapping
    //
    // Returns (eventName, parameters) ready to pass to Analytics.logEvent().
    // Parameter keys use the Firebase/GA4 reserved names where they exist
    // (item_id, item_name, value, currency) so dashboards are pre-populated.

    var analyticsPayload: (name: String, params: [String: Any]?) {
        switch self {

        case .login(let method):
            return (AnalyticsEventLogin, [AnalyticsParameterMethod: method])

        case .signup:
            return (AnalyticsEventSignUp, [AnalyticsParameterMethod: "email"])

        case .logout:
            return ("logout", nil)

        case .viewProduct(let id, let name, let category):
            return (AnalyticsEventViewItem, [
                AnalyticsParameterItemID: id,
                AnalyticsParameterItemName: name,
                AnalyticsParameterItemCategory: category
            ])

        case .viewMenu(let category):
            return ("view_menu", ["category": category])

        case .search(let query, let resultCount):
            return (AnalyticsEventSearch, [
                AnalyticsParameterSearchTerm: query,
                "result_count": resultCount
            ])

        case .addToCart(let id, let name, let price, let category):
            return (AnalyticsEventAddToCart, [
                AnalyticsParameterItemID: id,
                AnalyticsParameterItemName: name,
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemCategory: category,
                AnalyticsParameterCurrency: "USD"
            ])

        case .removeFromCart(let id, let name):
            return (AnalyticsEventRemoveFromCart, [
                AnalyticsParameterItemID: id,
                AnalyticsParameterItemName: name
            ])

        case .beginCheckout(let total, let itemCount, let paymentMethod):
            return (AnalyticsEventBeginCheckout, [
                AnalyticsParameterValue: total,
                AnalyticsParameterCurrency: "USD",
                "item_count": itemCount,
                "payment_method": paymentMethod
            ])

        case .purchase(let orderId, let total, let paymentMethod):
            return (AnalyticsEventPurchase, [
                AnalyticsParameterTransactionID: orderId,
                AnalyticsParameterValue: total,
                AnalyticsParameterCurrency: "USD",
                "payment_method": paymentMethod
            ])

        case .topUpWallet(let amount, let method):
            return ("wallet_top_up", [
                AnalyticsParameterValue: amount,
                AnalyticsParameterCurrency: "USD",
                "top_up_method": method
            ])
        }
    }
}

// MARK: - AnalyticsService

final class AnalyticsService {

    static let shared = AnalyticsService()
    let db = Firestore.firestore()
    private init() {}

    // MARK: - Public API

    /// Logs an analytics event.
    /// No-ops silently in the Dev environment so local testing
    /// doesn't pollute the Firebase console.
    func log(_ event: AnalyticsEvent) {
        guard Constants.currentEnv != .dev else { return }
        let (name, params) = event.analyticsPayload
        Analytics.logEvent(name, parameters: params)
        AppLog.firestore.debug("📊 Analytics — \(name)")
    }

    /// Attaches a persistent user ID to all subsequent events.
    /// Call immediately after a successful login or session restore.
    func setUser(id: String, role: String) {
        guard Constants.currentEnv != .dev else { return }
        Analytics.setUserID(id)
        Analytics.setUserProperty(role, forName: "user_role")
    }

    /// Clears the user ID (call on logout).
    func clearUser() {
        guard Constants.currentEnv != .dev else { return }
        Analytics.setUserID(nil)
        Analytics.setUserProperty(nil, forName: "user_role")
    }
}
