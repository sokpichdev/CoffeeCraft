# CoffeeCraft — Navigation

This document covers how the app navigates between screens: the entry point, the auth gate, tab routing, role-based tab filtering, and push notification deep-links.

---

## App Entry Point

`CoffeeCraftApp` is the `@main` struct. It creates a single `NavigationStack` and places `RootView` inside it. All global `@EnvironmentObject` values are injected at this level.

```
CoffeeCraftApp (@main)
  └─ NavigationStack
       └─ RootView
```

---

## Auth Gate (RootView)

`RootView` is the first view inside the `NavigationStack`. It checks `UserSession.isRestoring` before deciding what to render.

```
RootView
  ├─ CoffeeLoaderView          when session.isRestoring == true
  └─ Tab content + TabBarView  when session.isRestoring == false
```

`AuthViewModel` restores the session on launch by checking `Auth.auth().currentUser`. While the restore is in progress, `UserSession.isRestoring` is `true`, and `RootView` shows a full-screen loader. Once the restore completes — either by hydrating the previous session or confirming the user is signed out — the loader disappears and the appropriate screen is shown.

When no user is signed in, `ProductViewModel` returns no data and the tab content gracefully shows the unauthenticated state (the Auth module handles sign-in and registration inline).

---

## Tab Bar

`TabBarView` renders a custom animated tab bar at the bottom of the screen. It is driven by the `Tab` enum.

### Tab Enum

```swift
enum Tab: Int, CaseIterable {
    case dashboard  // Manager only
    case home
    case menu
    case orders
    case profile
}
```

`Tab.visible(for:)` returns the tabs the current user should see:

```swift
static func visible(for role: UserRole?) -> [Tab] {
    role == .manager ? Tab.allCases : Tab.allCases.filter { $0 != .dashboard }
}
```

- **Customers** see 4 tabs: Home, Menu, Orders, Account
- **Managers** see 5 tabs: Dashboard, Home, Menu, Orders, Account

`RootView` holds the `selectedTab: Tab` state and passes it as a `@Binding` to `TabBarView`. When the user taps a tab, `selectedTab` changes and `RootView` swaps the content view accordingly.

### Role-Based Content Swapping

`RootView` also swaps the content view for shared tabs based on role:

| Tab | Customer View | Manager View |
|---|---|---|
| Menu | `MenuView()` — browse and cart only | `MenuView(isManager: true)` — browse plus add/edit/delete controls |
| Orders | `OrdersView()` — customer's own order list | `AdminOrdersView()` — all orders with status update controls |
| Dashboard | Not shown | `AdminDashboardHomeView()` |

### Tab Switch After Account Change

When `session.currentUser` changes (i.e. a different account signs in), `RootView` resets `selectedTab` to `.home`. This prevents a customer session from inheriting `.dashboard` if a manager was previously signed in on the same device.

---

## Push Notification Deep-Links

FCM push notification taps are handled by `AppDelegate` and routed through `NotificationCoordinator`.

### Flow

1. User taps a push notification (e.g. "Your order is ready for pickup").
2. `AppDelegate.userNotificationCenter(_:didReceive:)` fires.
3. `AppDelegate` calls `NotificationCoordinator.shared.handleNotificationTap(userInfo:)`.
4. The coordinator parses the notification payload and sets `shouldNavigateToOrders = true` if applicable.
5. `RootView` observes `coordinator.shouldNavigateToOrders`:

```swift
.onChange(of: coordinator.shouldNavigateToOrders) { _, _ in
    selectedTab = .orders
}
```

6. The tab switches to Orders and the customer sees their order list.

The coordinator pattern keeps navigation logic out of `AppDelegate` and ensures the destination tab can react reactively rather than being called imperatively.

---

## In-Module Navigation

Within each module, navigation uses SwiftUI's `NavigationStack` / `navigationDestination` or the custom `PushLink` component from `Custom/Navigation/`. `PushLink` is a wrapper around `NavigationLink` that applies consistent styling and avoids the disclosure indicator shown by default.

`CustomNavigationBar` replaces the system navigation bar in screens that need a bespoke back button, title layout, or toolbar actions.

---

## Tab Bar Animation

The `TabBarView` tab buttons include an accessibility-aware bounce animation: on selection, the icon briefly jumps upward and optionally rotates. The animation is suppressed when `@Environment(\.accessibilityReduceMotion)` is `true`.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
```

When a tab is selected, a capsule highlight animates between tabs using a `matchedGeometryEffect` with the namespace ID `"Selected Tab"`.
