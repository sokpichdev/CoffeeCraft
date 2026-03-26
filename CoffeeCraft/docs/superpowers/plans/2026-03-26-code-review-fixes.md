# Code Review Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all Critical and Major code-review findings across the CoffeeCraft iOS app to make it production-ready.

**Architecture:** MVVM + Repository, SwiftUI + Firebase. All ViewModels are `@MainActor ObservableObject`. State mutations from async/Firestore callbacks must happen on the MainActor. Firestore writes that touch multiple documents atomically must use `db.runTransaction`.

**Tech Stack:** Swift 5.9+, SwiftUI, Firebase Firestore, Firebase Auth, Swift Concurrency (`async/await`, `@MainActor`, `Task`)

---

## Task 1: Fix CartManager — remove redundant DispatchQueue.main.async (CRIT-1)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Cart/ViewModel/CartManager.swift:78-109`

The class is `@MainActor`. The `DispatchQueue.main.async` wrappers inside `saveCartToFirestore` and `loadCartFromFirestore` are redundant and delay state mutations one extra run-loop. Remove them and wrap Firestore callbacks in `Task { @MainActor in }` instead.

- [ ] **Step 1: Update `saveCartToFirestore` — remove `DispatchQueue.main.async`**

Replace lines 78–96:
```swift
func saveCartToFirestore(userId: String, completion: (() -> Void)? = nil) {
    do {
        let data = try items.map { try Firestore.Encoder().encode($0) }
        db.collection(Firebase.Carts.collection).document(userId).setData([Firebase.Carts.items: data]) { [weak self] error in
            guard self != nil else { return }
            Task { @MainActor in
                if let error = error {
                    AlertManager.shared.showError(message: error.localizedDescription)
                } else {
                    completion?()
                }
            }
        }
    } catch {
        AlertManager.shared.showError(title: "Encoding error", message: error.localizedDescription)
    }
}
```

- [ ] **Step 2: Update `loadCartFromFirestore` — remove `DispatchQueue.main.async`**

Replace lines 98–109:
```swift
func loadCartFromFirestore(userId: String) {
    db.collection(Firebase.Carts.collection).document(userId).getDocument { [weak self] snapshot, error in
        if let error = error { AppLog.firestore.error("Error loading cart: \(error.localizedDescription)"); return }
        guard let data = snapshot?.data(), let itemData = data[Firebase.Carts.items] as? [[String: Any]] else { return }
        do {
            let decoded = try itemData.map { try Firestore.Decoder().decode(CartItem.self, from: $0) }
            Task { @MainActor in
                self?.items = decoded
                AppLog.printList(self?.items ?? [], label: "Fetched Carts")
            }
        } catch { AppLog.firestore.error("Decoding error: \(error.localizedDescription)") }
    }
}
```

- [ ] **Step 3: Build the project in Xcode and confirm no compiler errors in CartManager.swift**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Cart/ViewModel/CartManager.swift
git commit -m "fix: remove redundant DispatchQueue.main.async inside @MainActor CartManager"
```

---

## Task 2: Fix NotificationCoordinator — annotate @MainActor (CRIT-2)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Notification/NotificationCoordinator.swift`

`NotificationCoordinator` mutates `@Published` properties from an `NSNotificationCenter` callback. The `DispatchQueue.main.async` wrapper is manual and not compile-time enforced. Add `@MainActor` to the class and convert the handler to use `Task { @MainActor in }`.

- [ ] **Step 1: Replace entire file content**

```swift
import Combine
import SwiftUI

@MainActor
class NotificationCoordinator: ObservableObject {
    static let shared = NotificationCoordinator()

    @Published var selectedOrderId: String?
    @Published var shouldNavigateToOrders = false

    private init() {
        setupNotificationObserver()
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNavigateToOrder),
            name: Notification.Name("NavigateToOrder"),
            object: nil
        )
    }

    @objc private func handleNavigateToOrder(_ notification: Notification) {
        guard let orderId = notification.userInfo?["orderId"] as? String else { return }
        AppLog.firestore.debug("🔔 NotificationCoordinator: Navigating to order: \(orderId)")
        Task { @MainActor in
            self.selectedOrderId = orderId
            self.shouldNavigateToOrders = true
        }
    }

    func clearNavigation() {
        selectedOrderId = nil
        shouldNavigateToOrders = false
    }
}
```

- [ ] **Step 2: Build the project and confirm no compiler errors**

- [ ] **Step 3: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Notification/NotificationCoordinator.swift
git commit -m "fix: annotate NotificationCoordinator @MainActor, replace DispatchQueue with Task"
```

---

## Task 3: Fix OrderEnvironment — annotate @MainActor (CRIT-3)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Map/ViewModel/OrderEnvironment.swift:21`

`OrderEnvironment` mutates `@Published` dictionaries (`activeDeliverySessions`, `activeDeliveryVMs`) but has no `@MainActor` annotation. Adding it makes all property access compile-time guaranteed to be on the main actor.

- [ ] **Step 1: Add `@MainActor` to the class declaration on line 21**

Change:
```swift
final class OrderEnvironment: ObservableObject {
```
To:
```swift
@MainActor
final class OrderEnvironment: ObservableObject {
```

- [ ] **Step 2: Build and fix any resulting compiler errors**

If callers in `OrderViewModel` or `DeliveryRestoreService` call `activateDelivery`/`resumeDelivery` from non-`@MainActor` contexts, wrap those call sites in `Task { @MainActor in ... }`. Search for usages:

```bash
grep -rn "activateDelivery\|resumeDelivery\|beginRestoring\|endRestoring" CoffeeCraft/CoffeeCraft --include="*.swift"
```

For each call site that is in a Firestore snapshot closure or non-`@MainActor` context, wrap as:
```swift
Task { @MainActor in
    OrderEnvironment.shared.activateDelivery(order: updatedOrder)
}
```

- [ ] **Step 3: Build again to confirm clean compile**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Map/ViewModel/OrderEnvironment.swift
git commit -m "fix: annotate OrderEnvironment @MainActor to prevent data races on published properties"
```

---

## Task 4: Fix DeliveryMapView force unwraps (CRIT-4)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Map/Delivery/View/DeliveryMapView.swift:322-323`

Replace the force-unwrapped `lats.min()!` / `lats.max()!` with safe `guard let` bindings.

- [ ] **Step 1: Replace lines 320–323 in `regionFitting(coords:padding:)`**

Change:
```swift
let lats = coords.map(\.latitude)
let lngs = coords.map(\.longitude)
let minLat = lats.min()!, maxLat = lats.max()!
let minLng = lngs.min()!, maxLng = lngs.max()!
```
To:
```swift
let lats = coords.map(\.latitude)
let lngs = coords.map(\.longitude)
guard let minLat = lats.min(), let maxLat = lats.max(),
      let minLng = lngs.min(), let maxLng = lngs.max() else {
    return MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282),
        latitudinalMeters: 1000, longitudinalMeters: 1000
    )
}
```

- [ ] **Step 2: Also fix `DispatchQueue.main.asyncAfter` in `fitCamera` (MAJ-11, line 306)**

Change:
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
    isAutoZooming = false
}
```
To:
```swift
Task {
    try? await Task.sleep(for: .seconds(0.7))
    isAutoZooming = false
}
```

- [ ] **Step 3: Build and confirm no compiler errors**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Map/Delivery/View/DeliveryMapView.swift
git commit -m "fix: replace force unwraps and DispatchQueue.asyncAfter in DeliveryMapView"
```

---

## Task 5: Fix OrderDetailViewModel — atomic cancelOrder transaction (CRIT-5 + MAJ-10 + MIN-9)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Order/OrderDetail/ViewModel/OrderDetailViewModel.swift:33-84`

The current `cancelOrder()` does two sequential writes: update status then refund. If the app dies between them, the order is cancelled but no refund is issued. Replace with a single `db.runTransaction` that reads the current status server-side, writes the cancellation, and issues the refund ledger entry atomically.

- [ ] **Step 1: Replace `cancelOrder()` with a transaction-based implementation**

```swift
func cancelOrder() async {
    guard let orderId = order.id else { return }
    guard order.orderStatus == .pending else {
        AlertManager.shared.showError(message: "Only Pending orders can be cancelled.")
        return
    }

    isCancelling = true
    defer { isCancelling = false }

    AppLog.order.info("Cancelling order \(orderId) — payment: \(self.order.paymentMethod ?? "cash")")

    let wasWalletPayment = order.wasWalletPayment
    let userId = order.userId
    let walletAmountPaid = order.walletAmountPaid ?? 0

    do {
        try await db.runTransaction { transaction, errorPointer in
            // 1. Read current order status server-side (prevents stale local state)
            let orderRef = self.db.collection(Firebase.Orders.collection).document(orderId)
            let orderSnap: DocumentSnapshot
            do {
                orderSnap = try transaction.getDocument(orderRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard let currentStatus = orderSnap.data()?[Firebase.Orders.status] as? String,
                  currentStatus == OrderStatus.pending.rawValue else {
                let err = NSError(domain: "CoffeeCraft", code: 409,
                                  userInfo: [NSLocalizedDescriptionKey: "Order is no longer Pending and cannot be cancelled."])
                errorPointer?.pointee = err
                return nil
            }

            // 2. Mark order Cancelled
            transaction.updateData([Firebase.Orders.status: OrderStatus.cancelled.rawValue], forDocument: orderRef)

            // 3. Atomic wallet refund (if wallet-paid)
            if wasWalletPayment, let uid = userId, walletAmountPaid > 0 {
                let walletRef = self.db.collection(Firebase.Wallets.collection).document(uid)
                transaction.updateData([Firebase.Wallets.balance: FieldValue.increment(walletAmountPaid)], forDocument: walletRef)

                let txRef = self.db.collection(Firebase.WalletTransactions.collection).document()
                transaction.setData([
                    Firebase.WalletTransactions.userId: uid,
                    Firebase.WalletTransactions.amount: walletAmountPaid,
                    Firebase.WalletTransactions.type: "refund",
                    Firebase.WalletTransactions.orderId: orderId,
                    Firebase.WalletTransactions.createdAt: Timestamp(date: Date())
                ], forDocument: txRef)
            }
            return nil
        }

        AppLog.order.debug("Order \(orderId) cancelled atomically")

        if wasWalletPayment, walletAmountPaid > 0 {
            ToastManager.shared.showTop(
                message: "Order cancelled · +\(walletAmountPaid.currencyFormatted) refunded to wallet",
                type: .success
            )
        } else {
            ToastManager.shared.showTop(message: "Order cancelled", type: .success)
        }
    } catch {
        AppLog.order.error("cancelOrder failed: \(error.localizedDescription)")
        AlertManager.shared.showError(
            title: "Cancellation failed",
            message: error.localizedDescription
        )
    }
}
```

> **Note:** Check `FirebaseKeys.swift` for the exact constant names for `Firebase.Wallets`, `Firebase.WalletTransactions`. If they don't exist, use the string literals and add constants in the same commit.

- [ ] **Step 2: Verify FirebaseKeys constants exist for Wallets and WalletTransactions**

```bash
grep -n "Wallets\|WalletTransactions" CoffeeCraft/CoffeeCraft/Constants/FirebaseKeys.swift
```

Add any missing constants to `FirebaseKeys.swift` before building.

- [ ] **Step 3: Build and confirm no compiler errors**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Order/OrderDetail/ViewModel/OrderDetailViewModel.swift
git add CoffeeCraft/CoffeeCraft/Constants/FirebaseKeys.swift
git commit -m "fix: make cancelOrder atomic with db.runTransaction — prevents refund loss on app kill"
```

---

## Task 6: Fix OrderDetailViewModel.fetchUserInfo — convert to async/await (MAJ-1)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Order/OrderDetail/ViewModel/OrderDetailViewModel.swift:131-149`

- [ ] **Step 1: Replace `fetchUserInfo` with an async version**

```swift
func fetchUserInfo(userId: String) {
    Task {
        defer { isLoadingUser = false }
        isLoadingUser = true
        do {
            let snapshot = try await db.collection(Firebase.Users.collection).document(userId).getDocument()
            if let name = snapshot.data()?[Firebase.Users.name] as? String {
                self.userName = name
            } else {
                self.userName = "User #\(userId.suffix(6))"
            }
        } catch {
            AppLog.order.error("Failed to fetch user: \(error.localizedDescription)")
            self.userName = "Unknown User"
        }
    }
}
```

> **Note:** Verify `Firebase.Users.name` constant exists. If not, use `"name"` literal and add the constant to `FirebaseKeys.swift`.

- [ ] **Step 2: Build and confirm no errors**

- [ ] **Step 3: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Order/OrderDetail/ViewModel/OrderDetailViewModel.swift
git commit -m "fix: convert fetchUserInfo to async/await, remove callback+Task nesting"
```

---

## Task 7: Fix MapViewModel — annotate @MainActor (MAJ-2)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Map/ViewModel/MapViewModel.swift`

`MapViewModel` uses `@Observable` but mutates properties from a Firestore callback via `DispatchQueue.main.async`. Add `@MainActor` and use `Task { @MainActor in }` in the callback.

- [ ] **Step 1: Add `@MainActor` to `MapViewModel` class declaration**

Find the class declaration line (likely `@Observable class MapViewModel`) and change to:
```swift
@MainActor
@Observable
class MapViewModel {
```

- [ ] **Step 2: Update `fetchBranches` — replace `DispatchQueue.main.async`**

Change:
```swift
func fetchBranches() {
    isOffline = !NetworkMonitor.shared.isConnected
    BranchRepository.shared.listen { [weak self] updatedBranches in
        guard let self else { return }
        DispatchQueue.main.async {
            self.branches  = updatedBranches
            self.isOffline = !NetworkMonitor.shared.isConnected
        }
    }
}
```
To:
```swift
func fetchBranches() {
    isOffline = !NetworkMonitor.shared.isConnected
    BranchRepository.shared.listen { [weak self] updatedBranches in
        guard let self else { return }
        Task { @MainActor in
            self.branches  = updatedBranches
            self.isOffline = !NetworkMonitor.shared.isConnected
        }
    }
}
```

- [ ] **Step 3: Build and fix any caller-side `@MainActor` errors**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Map/ViewModel/MapViewModel.swift
git commit -m "fix: annotate MapViewModel @MainActor, replace DispatchQueue with Task in fetchBranches"
```

---

## Task 8: Fix MenuView — remove rogue AuthViewModel (MAJ-3)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Menu/View/MenuView.swift:19`

`MenuView` owns `@StateObject private var authVM = AuthViewModel()`. This creates a second `AuthViewModel` on every tab switch, registering a second FCM observer. The correct `AuthViewModel` is already injected via `@EnvironmentObject` from `CoffeeCraftApp`.

- [ ] **Step 1: Remove the `@StateObject` declaration and add an `@EnvironmentObject`**

Remove line 19:
```swift
@StateObject private var authVM = AuthViewModel()
```

Add instead (with the other `@EnvironmentObject` declarations at the top of the struct):
```swift
@EnvironmentObject var authVM: AuthViewModel
```

- [ ] **Step 2: Verify all usages of `authVM` in `MenuView` still compile**

Search for all uses in the file:
```bash
grep -n "authVM" CoffeeCraft/CoffeeCraft/Module/Menu/View/MenuView.swift
```

The `authVM` is already available from the environment since `RootView` passes `authVM` down. No other changes should be required.

- [ ] **Step 3: Build and confirm no compiler errors**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Menu/View/MenuView.swift
git commit -m "fix: remove rogue @StateObject AuthViewModel from MenuView, use @EnvironmentObject"
```

---

## Task 9: Fix RootView — use injected session instead of UserSession.shared (MAJ-4)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Main/View/RootView.swift:42,60,82,87,92`

`RootView` has an `@EnvironmentObject var session: UserSession` but reads `UserSession.shared.currentUser?.role` directly on lines 42 and 60, and `UserSession.shared.currentUser` / `UserSession.shared.userId` on lines 82, 87, 92.

- [ ] **Step 1: Replace all `UserSession.shared` references in RootView with `session`**

Line 42: `if UserSession.shared.currentUser?.role == .manager` → `if session.currentUser?.role == .manager`

Line 60: `if UserSession.shared.currentUser?.role == .manager` → `if session.currentUser?.role == .manager`

Line 82: `if UserSession.shared.currentUser != nil` → `if session.currentUser != nil`

Line 87: `if let userId = UserSession.shared.userId` → `if let userId = session.userId`

Line 92: `.onChange(of: UserSession.shared.currentUser)` → `.onChange(of: session.currentUser)`

- [ ] **Step 2: Build and confirm no errors**

- [ ] **Step 3: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Main/View/RootView.swift
git commit -m "fix: replace UserSession.shared direct access in RootView with injected @EnvironmentObject"
```

---

## Task 10: Fix retain cycles in AlertManager closures (MAJ-5)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/AdminDashboard/DashBoardSummary/ViewModel/DashboardHomeViewModel.swift:124`
- Modify: `CoffeeCraft/CoffeeCraft/Module/AdminDashboard/SalesAnalytics/ViewModel/SalesAnalyticsViewModel.swift:73`

Both ViewModels capture `self` strongly in closures passed to `AlertManager.shared`, creating a potential retain cycle.

- [ ] **Step 1: Fix DashboardHomeViewModel — add `[weak self]`**

Find line 124 which contains:
```swift
onConfirm: { Task { await self.loadSummary() } }
```
Change to:
```swift
onConfirm: { [weak self] in Task { await self?.loadSummary() } }
```

- [ ] **Step 2: Fix SalesAnalyticsViewModel — find and fix the equivalent closure**

Open the file and find the `AlertManager.shared.showConfirmation` call around line 73. Apply the same `[weak self]` pattern.

- [ ] **Step 3: Build and confirm no errors**

- [ ] **Step 4: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/AdminDashboard/DashBoardSummary/ViewModel/DashboardHomeViewModel.swift
git add CoffeeCraft/CoffeeCraft/Module/AdminDashboard/SalesAnalytics/ViewModel/SalesAnalyticsViewModel.swift
git commit -m "fix: add [weak self] to AlertManager retry closures to prevent retain cycles"
```

---

## Task 11: Fix CardViewModel.setActiveCard — remove nested Task in defer (MAJ-6)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Account/Puchase-Cards/ViewModel/CardViewModel.swift:235`

- [ ] **Step 1: Change the defer on line 235**

Change:
```swift
defer { Task { @MainActor in isLoading = false } }
```
To:
```swift
defer { isLoading = false }
```

The method is `@MainActor` so this is safe and avoids the deferred run-loop hop.

- [ ] **Step 2: Build and confirm no errors**

- [ ] **Step 3: Also fix the hardcoded `"accessibleCards"` string on line 173 (MIN-7)**

Change:
```swift
try await db.collection(Firebase.Users.collection).document(userId).updateData([
    "accessibleCards": FieldValue.arrayUnion([cleanCardNumber])
])
```
To:
```swift
try await db.collection(Firebase.Users.collection).document(userId).updateData([
    Firebase.Users.accessibleCards: FieldValue.arrayUnion([cleanCardNumber])
])
```

- [ ] **Step 4: Build and confirm no errors**

- [ ] **Step 5: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Account/Puchase-Cards/ViewModel/CardViewModel.swift
git commit -m "fix: remove unnecessary Task wrapper in defer, fix hardcoded accessibleCards string"
```

---

## Task 12: Fix FavoriteViewModel — handle Firestore errors in loadFavoriteState (MAJ-7 + MIN-8)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Favorites/ViewModel/FavoriteViewModel.swift:56-64`
- Modify: `CoffeeCraft/CoffeeCraft/Module/Favorites/ViewModel/FavoriteViewModel.swift:109-117`

- [ ] **Step 1: Replace `try?` with `do/try/catch` in `loadFavoriteState`**

Change lines 56–64:
```swift
let snapshot = try? await db
    .collection(Firebase.Users.collection)
    .document(userId)
    .collection(Firebase.Users.Favorites.collection)
    .whereField(Firebase.Users.Favorites.productId, isEqualTo: product.id)
    .whereField(Firebase.Users.Favorites.customizationHash, isEqualTo: hash)
    .getDocuments()

isFavorite = !(snapshot?.documents.isEmpty ?? true)
```
To:
```swift
do {
    let snapshot = try await db
        .collection(Firebase.Users.collection)
        .document(userId)
        .collection(Firebase.Users.Favorites.collection)
        .whereField(Firebase.Users.Favorites.productId, isEqualTo: product.id)
        .whereField(Firebase.Users.Favorites.customizationHash, isEqualTo: hash)
        .getDocuments()
    isFavorite = !snapshot.documents.isEmpty
} catch {
    AppLog.menu.error("❌ loadFavoriteState — fetch failed: \(error.localizedDescription)")
    // Do not reset isFavorite — keep the last known state rather than falsely showing unfavorited
}
```

- [ ] **Step 2: Replace raw string field keys in `toggleFavorite` with constants (MIN-8)**

Find the `addDocument(data:)` call in `toggleFavorite` (around line 109) and replace raw strings:
```swift
let docRef = try await ref.addDocument(data: [
    Firebase.Users.Favorites.productId: product.id,
    Firebase.Users.Favorites.productName: product.name,
    Firebase.Users.Favorites.imageURL: product.imageURL,
    Firebase.Users.Favorites.basePrice: product.price,
    Firebase.Users.Favorites.customizations: customizations,
    Firebase.Users.Favorites.customizationHash: hash,
    Firebase.Users.Favorites.createdAt: Date()
])
```

> **Note:** Check which constants exist in `FirebaseKeys.swift` under `Firebase.Users.Favorites`. If any are missing (e.g., `productName`, `imageURL`, `basePrice`, `createdAt`), add them to `FirebaseKeys.swift` first.

- [ ] **Step 3: Add any missing FirebaseKeys.swift constants for Favorites fields**

```bash
grep -n "Favorites" CoffeeCraft/CoffeeCraft/Constants/FirebaseKeys.swift
```

Add any missing ones under the `Favorites` nested enum.

- [ ] **Step 4: Build and confirm no errors**

- [ ] **Step 5: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Favorites/ViewModel/FavoriteViewModel.swift
git add CoffeeCraft/CoffeeCraft/Constants/FirebaseKeys.swift
git commit -m "fix: handle Firestore errors in loadFavoriteState, replace raw string keys with constants"
```

---

## Task 13: Fix AnalyticsService — use count aggregation for order summary (MAJ-9)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/AdminDashboard/Services_Analytics/AnalyticsService+Dashboard.swift:79-104`

Replace the three `getDocuments()` calls in `fetchOrderSummary()` with `count.getAggregation(source: .server)` queries (same pattern already used in `fetchCustomerSummary`).

- [ ] **Step 1: Replace `fetchOrderSummary` with aggregation-based implementation**

```swift
private func fetchOrderSummary() async throws -> OrderSummary {
    let now = Date()
    let todayStart = Calendar.current.startOfDay(for: now)
    let yesterdayStart = Calendar.current.date(byAdding: .day, value: -1, to: todayStart)!

    async let todayAgg = db.collection(Firebase.Orders.collection)
        .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: todayStart))
        .count
        .getAggregation(source: .server)

    async let yesterdayAgg = db.collection(Firebase.Orders.collection)
        .whereField(Firebase.Orders.timestamp, isGreaterThanOrEqualTo: Timestamp(date: yesterdayStart))
        .whereField(Firebase.Orders.timestamp, isLessThan: Timestamp(date: todayStart))
        .count
        .getAggregation(source: .server)

    async let activeAgg = db.collection(Firebase.Orders.collection)
        .whereField(Firebase.Orders.status, in: OrderStatus.activeRawValues)
        .count
        .getAggregation(source: .server)

    let (today, yesterday, active) = try await (todayAgg, yesterdayAgg, activeAgg)

    return OrderSummary(
        todayCount: Int(truncating: today.count),
        yesterdayCount: Int(truncating: yesterday.count),
        activeCount: Int(truncating: active.count)
    )
}
```

- [ ] **Step 2: Build and confirm no errors**

- [ ] **Step 3: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/AdminDashboard/Services_Analytics/AnalyticsService+Dashboard.swift
git commit -m "perf: replace getDocuments with count aggregation in fetchOrderSummary"
```

---

## Task 14: Fix OrdersView deep-link — replace DispatchQueue.main.asyncAfter (MIN-10)

**Files:**
- Modify: `CoffeeCraft/CoffeeCraft/Module/Order/OrderListing/View/OrdersView.swift:158`

- [ ] **Step 1: Replace `DispatchQueue.main.asyncAfter` with `Task.sleep`**

Change lines 157–160:
```swift
} else {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        navigateToLinkedOrder(orderId: orderId)
    }
}
```
To:
```swift
} else {
    Task {
        try? await Task.sleep(for: .seconds(1))
        navigateToLinkedOrder(orderId: orderId)
    }
}
```

- [ ] **Step 2: Build and confirm no errors**

- [ ] **Step 3: Commit**
```bash
git add CoffeeCraft/CoffeeCraft/Module/Order/OrderListing/View/OrdersView.swift
git commit -m "fix: replace DispatchQueue.main.asyncAfter with Task.sleep in OrdersView deep-link"
```

---

## Task 15: Final build verification

- [ ] **Step 1: Clean build**

In Xcode: Product → Clean Build Folder (⇧⌘K), then Build (⌘B).

- [ ] **Step 2: Confirm zero warnings related to `DispatchQueue.main`, threading, or force unwraps in modified files**

- [ ] **Step 3: Smoke-test critical flows**
  - Add item to cart → remove → verify no crash
  - Cancel a pending order in-app and verify the wallet balance updates atomically
  - Switch to Menu tab → confirm no second AuthViewModel init in Xcode console
  - Open delivery map → verify camera fitting works without crash

- [ ] **Step 4: Final commit if any last-minute fixes were made**
```bash
git add -p
git commit -m "fix: final clean-up from code-review pass"
```
