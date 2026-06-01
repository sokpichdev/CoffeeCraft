# Rewards / Loyalty Points Module

**Status:** Implemented (Phase 8)
**Last updated:** 2026-03-30

---

## Overview

The Rewards module gives customers loyalty points every time an order is completed. Points accumulate on the customer's active loyalty card. Every 10 points earned triggers an automatic $20.00 wallet credit. A dedicated Rewards screen (accessible from the Account tab) shows the active card, a live progress bar toward the next milestone, and a scrollable points history.

---

## User Story

> As a customer, I want to earn points on every completed order so that I can receive wallet credits as a reward for my loyalty.

---

## Architecture

The module follows the same MVVM + Service pattern used throughout the app.

```
AccountView
  └─ RewardsView
       ├─ CardViewModel          (@EnvironmentObject, shared from AccountView)
       ├─ RewardsViewModel       (@StateObject, owned by RewardsView)
       │    └─ Firestore snapshot listener on points_transactions
       └─ LoyaltyService.shared
            ├─ loyalty_cards     (Firestore read + runTransaction)
            ├─ points_transactions (written inside runTransaction)
            └─ WalletService.shared.addReward() (milestone credit)
```

Points are awarded on the **manager side**:

```
AdminOrdersViewModel.updateOrderStatus(status: "completed")
  └─ Task { LoyaltyService.shared.awardPoints(...) }   // detached, try?
```

---

## File Map

| File | Role |
|------|------|
| `Module/Rewards/Service/LoyaltyService.swift` | Singleton service — awards points and detects milestones |
| `Module/Rewards/MVVM/Model/PointsTransaction.swift` | Codable model for a single points history entry |
| `Module/Rewards/MVVM/ViewModel/RewardsViewModel.swift` | `@MainActor ObservableObject` — owns the live history listener |
| `Module/Rewards/MVVM/View/RewardsView.swift` | Main rewards screen |
| `Module/Rewards/MVVM/View/PointsProgressView.swift` | Animated gradient progress bar |
| `Module/Rewards/MVVM/View/PointsTransactionRow.swift` | Single row in the history list |
| `Constants/FirebaseKeys.swift` | `Firebase.PointsTransactions` and updated `Firebase.Products` / `Firebase.Orders.ItemField` |
| `Module/Order/OrderListing/ViewModel/AdminOrdersViewModel.swift` | Calls `LoyaltyService` after a status update to `completed` |
| `Module/Order/OrderListing/Firebase/OrderService.swift` | Snapshots `pointsValue` per item into the order document at checkout |
| `Module/Order/OrderListing/Model/Order.swift` | `CartItemData.pointsValue: Double?` (optional for backward compatibility) |
| `Module/Menu/Product/Model/Product.swift` | `Product.pointsValue: Double` |
| `Repository/Product/FirestoreProductRepository.swift` | Encodes and decodes `pointsValue` in `save()` and `parse()` |
| `Module/Menu/Product/View/EditProductView.swift` | `CustomNumberField` for managers to set `pointsValue` per product |
| `Module/Menu/View/MenuView.swift` | Passes `pointsValue` to `EditProductView` |
| `Module/Account/View/AccountView.swift` | Navigation destination for `RewardsView` |
| `Utilize/AppLog.swift` | `AppLog.rewards` logger (`category: "Rewards"`) |

---

## Data Flow

### Earning Points (manager action)

```
Manager taps "Complete" on an order in AdminOrdersView
  → AdminOrdersViewModel.updateOrderStatus(status: "completed")
      → Firestore write to orders/{orderId}.status = "completed"  ← always happens
      → Task {
          LoyaltyService.shared.awardPoints(
            userId:           order.userId,
            orderId:          order.id,
            points:           sum of (item.pointsValue * item.quantity),
            orderDescription: "Order #\(order.orderId)"
          )
        }                                                          ← fire-and-forget (try?)
```

The `try?` is intentional. A network failure during point award must not block or roll back the order status update.

### Inside `LoyaltyService.awardPoints`

```
1. Fetch users/{userId}.activeCard
     └─ If nil or empty → return early (no card, no points)

2. Query loyalty_cards WHERE cardNumber == activeCard
     └─ Resolve document reference

3. db.runTransaction {
     a. Read card.points (current Int value)
     b. Write card.points = current + roundedPoints
     c. Write points_transactions/{autoId} = {
          userId, cardNumber, orderId, points (raw Double), description, timestamp
        }
   }                                   ← atomic: both succeed or both fail

4. Milestone check (outside transaction, on result):
     pointsBefore / 10  <  pointsAfter / 10
     └─ For each milestone crossed:
          WalletService.shared.addReward(userId:, amount: 20.00, reason: "Loyalty reward")

5. Task { @MainActor in
     ToastManager.shared.show("You earned \(pointsInt) pts!")
   }
```

> Note: `LoyaltyService` is NOT `@MainActor`. Firestore's `runTransaction` closure runs synchronously on a background thread and will deadlock if the actor executor is involved. Any UI calls (e.g. `ToastManager`) must be dispatched back with `Task { @MainActor in ... }`.

### Viewing Points (customer action)

```
AccountView → ShortcutsSection "Rewards" row (auth-gated)
  → showRewards = true
  → NavigationDestination → RewardsView
       .onAppear  → rewardsVM.setup(userId:)
                     └─ Attaches Firestore listener:
                          points_transactions
                            WHERE userId == currentUser
                            ORDER BY timestamp DESC
                            LIMIT 50
       .onDisappear → rewardsVM.teardown()  ← removes listener
```

---

## Key Design Decisions

### Points type: `Double` on the wire, `Int` on the card

`Product.pointsValue` is a `Double` to allow fractional configuration (e.g. 1.5 pts for a small coffee). `LoyaltyCard.points` is an `Int` in Firestore (pre-existing schema). `LoyaltyService` rounds the accumulated `Double` to the nearest `Int` before writing to the card. The raw `Double` is preserved in `points_transactions.points` for auditability.

### Points are snapshotted at order time

`OrderService.buildOrderData()` writes `pointsValue` per item into the order document. This means point values are locked in at the moment the customer places an order, not at the moment the manager completes it. If a manager changes a product's `pointsValue` later, existing orders are unaffected.

### Atomic card update and ledger write

Both the card increment and the `points_transactions` record are written inside a single `db.runTransaction`. This prevents the card balance and the history from ever being out of sync — either both are written or neither is.

### Milestone detection

```swift
let pointsBefore = card.points         // Int value before award
let pointsAfter  = pointsBefore + roundedPoints

let milestonesBefore = pointsBefore / 10
let milestonesAfter  = pointsAfter  / 10

let newMilestones = milestonesAfter - milestonesBefore
// newMilestones > 0 means at least one $20 credit is owed
```

Multiple milestones in a single order each trigger a separate `addReward` call.

---

## Firestore Schema

### Collection: `products` (updated)

| Field | Type | Notes |
|-------|------|-------|
| `pointsValue` | number (Double) | Points awarded when this product appears in a completed order. Default: `0.0`. |

### Collection: `orders` — items array (updated)

Each element in the `items` array now includes:

| Field | Type | Notes |
|-------|------|-------|
| `pointsValue` | number (Double) | Snapshot of the product's `pointsValue` at time of order. Optional — absent on legacy orders. |

### New collection: `points_transactions`

| Field | Type | Notes |
|-------|------|-------|
| `userId` | string | Firebase Auth UID of the customer who earned the points. |
| `cardNumber` | string | The card number that received the points (snapshot of `activeCard` at award time). |
| `orderId` | string | Firestore document ID of the completed order. |
| `points` | number (Double) | Raw point value, e.g. `3.5`. Stored as Double for audit trail. |
| `description` | string | Human-readable label, e.g. `"Order #42"`. |
| `timestamp` | Timestamp | Server timestamp of award. |

**Required Firestore composite index** (must be created manually in the Firebase Console before the history query will work):

```
Collection:  points_transactions
Fields:      userId ASC, timestamp DESC
```

### Collection: `loyalty_cards` (read + written by LoyaltyService)

`LoyaltyService` reads and updates the `points` field (Int) on this collection. The full schema for `loyalty_cards` is documented in the main Firestore schema reference.

---

## Models

### `PointsTransaction`

```swift
struct PointsTransaction: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var cardNumber: String
    var orderId: String?
    var points: Double        // raw Double, e.g. 1.5
    var description: String   // e.g. "Order #42"
    var timestamp: Date
}
```

Decoded directly from Firestore via `@DocumentID` and `Codable`. The `orderId` is optional to accommodate any future non-order award types.

### `LoyaltyCard.points` (existing model, updated by this module)

`LoyaltyCard.points` is `Int`. `LoyaltyService` rounds the incoming `Double` with `.rounded()` before adding to this field. The model lives in `Module/Account/Puchase-Cards/Model/Card.swift`.

---

## ViewModels

### `RewardsViewModel`

`@MainActor ObservableObject`. Manages the Firestore snapshot listener for the points history.

**Published properties:**

| Property | Type | Description |
|----------|------|-------------|
| `pointsHistory` | `[PointsTransaction]` | The 50 most recent transactions for the current user, newest first. |
| `isLoadingHistory` | `Bool` | `true` while the first snapshot is being loaded. Used to show shimmer skeleton. |

**Methods:**

- `setup(userId: String)` — attaches the snapshot listener. Call from `RewardsView.onAppear`.
- `teardown()` — removes the listener and clears `pointsHistory`. Call from `RewardsView.onDisappear`.

Calling `setup` before `teardown` on a previous session will detach the old listener first.

### `LoyaltyService`

Singleton (`LoyaltyService.shared`). Not `@MainActor` by design — see the threading note above.

```swift
func awardPoints(
    userId: String,
    orderId: String,
    points: Double,
    orderDescription: String
) async throws
```

Throws on Firestore errors. Call sites use `try?` so failures are silent to the caller. Failures are logged via `AppLog.rewards`.

---

## Views

### `RewardsView`

Entry point for the rewards screen. Navigated to from `AccountView` via `.navigationDestination(isPresented: $showRewards)`.

Dependencies:
- `@EnvironmentObject var cardVM: CardViewModel` — provides the active `LoyaltyCard` for `FlippableCardView`.
- `@StateObject var rewardsVM: RewardsViewModel` — owned by this view.

Sections:
1. `FlippableCardView` — the customer's active loyalty card (existing reusable component).
2. `PointsProgressView` — progress bar toward next 10-point milestone.
3. Points history list — `PointsTransactionRow` per entry, shimmer skeleton while loading, empty state when history is empty.

### `PointsProgressView`

Displays `X / 10 pts toward next reward` and `+$20.00 at N pts`. The progress bar uses a `LinearGradient` from `Color.accentPrimary` to `Color.accentGold` and animates on value change.

Progress within the current milestone is calculated as:

```swift
let progress = Double(card.points % 10) / 10.0
```

### `PointsTransactionRow`

Single-row component for the history list. Shows a gold star icon, the `description` string, a relative date, and a `+N pts` badge in a capsule shape. The badge displays the points value rounded to the nearest integer for readability, even though the raw `Double` is stored.

---

## Manager Workflow: Setting Points on a Product

1. Open the Menu tab as a manager.
2. Tap a product to open `EditProductView`.
3. In the Basic Info section, find the **Points Value** field (`CustomNumberField` with `star.circle.fill` icon).
4. Enter the number of points a customer earns when this product appears in a completed order (e.g. `2` for a specialty drink, `1` for a basic coffee).
5. Tap Save.

The value is written to `products/{productId}.pointsValue` and will apply to all future orders containing this product.

---

## Known Constraints and Limitations

- **No retry on award failure.** `awardPoints` is called with `try?`. If the device is offline or Firestore returns an error at completion time, those points are permanently lost for that order. There is no queue or retry mechanism.

- **History capped at 50 entries.** The Firestore listener uses `.limit(to: 50)`. There is no pagination UI for older transactions.

- **Integer rounding.** Points are stored as `Int` on `LoyaltyCard` because that schema predates this module. Fractional points set on a product (e.g. `0.5`) are rounded to the nearest integer before being added to the card total. The raw `Double` is preserved in `points_transactions` only.

- **Active card required at award time.** If the customer has no active card when the order is completed, `LoyaltyService` returns early and no points are recorded. Points are not back-credited if the customer activates a card later.

- **Manual Firestore index required.** The `points_transactions` query (`userId ASC, timestamp DESC`) will fail with a Firestore error until the composite index is created in the Firebase Console. The app will show an empty history list rather than an error in this case.

- **Toast delivery is best-effort.** The toast shown on point award fires on a background task and appears the next time the customer's app is in the foreground on the same session. It is not delivered as a push notification.
