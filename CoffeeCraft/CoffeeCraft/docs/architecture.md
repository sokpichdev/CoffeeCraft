# CoffeeCraft — Architecture

This document explains the MVVM + Repository architecture used throughout CoffeeCraft, how dependencies flow between layers, and the strategies used for real-time data.

---

## Pattern Overview

```
View (SwiftUI)
  └─ ViewModel (@MainActor, @Published state)
       └─ Repository Protocol
            └─ Firebase Repository (Firestore / Firebase Auth)
                  └─ Firestore / Firebase Auth SDK
```

Each layer has a single responsibility:

- **View** — declarative UI, no business logic, observes `@Published` state from its ViewModel
- **ViewModel** — business logic, state management, async coordination; always marked `@MainActor` to ensure `@Published` mutations happen on the main thread
- **Repository Protocol** — abstracts all Firebase interactions behind a Swift protocol so ViewModels can be tested without a real Firestore connection
- **Firebase Repository** — the concrete implementation; the only layer that imports Firebase

---

## Repository Protocols

Four domains have full repository protocol coverage:

| Protocol | Firebase Implementation | Primary ViewModel |
|---|---|---|
| `AuthRepositoryProtocol` | `FirebaseAuthRepository` | `AuthViewModel` |
| `ProductRepositoryProtocol` | `FirestoreProductRepository` | `ProductViewModel` |
| `OrderRepositoryProtocol` | `FirestoreOrderRepository` | `OrderViewModel`, `AdminOrdersViewModel` |
| `WalletRepositoryProtocol` | `FirestoreWalletRepository` | `WalletViewModel` |

Repository files live in `CoffeeCraft/Repository/<Domain>/`. The protocol and its Firebase implementation share the same folder.

### Injecting a Repository

ViewModels accept the repository through an initializer parameter with a default value pointing to the Firebase implementation:

```swift
final class OrderViewModel: ObservableObject {
    private let repo: OrderRepositoryProtocol

    init(repo: OrderRepositoryProtocol = FirestoreOrderRepository()) {
        self.repo = repo
    }
}
```

In unit tests, pass a mock that conforms to the protocol. The View layer never changes.

---

## Dependency Injection via EnvironmentObject

`CoffeeCraftApp` is the single injection site for global state. Every object listed below is created once at app launch and injected into the view hierarchy via `.environmentObject()`.

```swift
// CoffeeCraftApp.swift
@main
struct CoffeeCraftApp: App {
    @StateObject private var session = UserSession.shared
    @StateObject var authVM = AuthViewModel()
    @StateObject private var orderVM = OrderViewModel()
    @StateObject private var coordinator = NotificationCoordinator.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var walletVM = WalletViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .environmentObject(session)
                    .environmentObject(authVM)
                    .environmentObject(orderVM)
                    .environmentObject(coordinator)
                    .environmentObject(walletVM)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.theme.colorScheme)
                    .id(themeManager.palette.rawValue)
            }
            .applyApiUIComponents()
        }
    }
}
```

### Global EnvironmentObjects

These are accessible from any View in the hierarchy:

| Object | Type | Purpose |
|---|---|---|
| `UserSession.shared` | `UserSession` | Current user, role, auth state, Crashlytics identity |
| `AuthViewModel` | `AuthViewModel` | Auth lifecycle: sign-in, registration, session restore, password reset |
| `OrderViewModel` | `OrderViewModel` | Real-time customer orders with cursor-based pagination |
| `WalletViewModel` | `WalletViewModel` | Real-time wallet balance and transaction list |
| `ThemeManager.shared` | `ThemeManager` | Appearance mode and color palette |
| `NotificationCoordinator.shared` | `NotificationCoordinator` | Deep-link routing from push notification taps |

### Scene-Scoped Objects

Created by `RootView` and passed down only to the tabs that need them:

| Object | Purpose |
|---|---|
| `CartManager` | Shopping cart with Firestore sync |
| `ProductViewModel` | Product catalog and CRUD |
| `FavoriteViewModel` | Wishlist |
| `CardViewModel` | Loyalty cards |
| `AnnouncementViewModel` | Home screen announcements |
| `InboxViewModel` | Notification inbox |

### Direct Singletons

Accessed directly without injection — available anywhere via `Singleton.shared`:

| Object | Purpose |
|---|---|
| `AlertManager.shared` | Global alert/error dialogs |
| `ToastManager.shared` | Transient toast notifications |
| `LoaderManager.shared` | Full-screen loading spinner |
| `NetworkMonitor.shared` | Connectivity detection |
| `WalletService.shared` | All atomic wallet mutations |

---

## Real-Time Data Strategy

Three different mechanisms handle live data depending on the use case.

### 1. Snapshot Listeners

Used for data that must stay live for the entire app session. The listener is attached when the ViewModel's `setup()` method is called and removed in `deinit`.

Used for:
- Products (catalog updates, availability changes)
- Wallet balance
- Wallet transactions (most recent 50)
- Notification inbox

```swift
// Pattern used in WalletViewModel via WalletRepositoryProtocol
private var cancelWallet: (() -> Void)?

func setup(userId: String) {
    cancelWallet = repo.listenWallet(userId: userId) { [weak self] wallet in
        self?.wallet = wallet
    }
}

deinit {
    cancelWallet?()
}
```

The `WalletRepositoryProtocol.listenWallet` method returns a `() -> Void` cancel closure so the protocol has zero Firebase imports, making it trivial to mock.

### 2. Cursor-Based Pagination with Live Listener

Used for the customer Orders list. Orders are paginated in pages of 5, but the active listener covers all loaded documents, not just the latest page.

When the user scrolls to the bottom:
1. The last loaded document's snapshot is used as a Firestore cursor.
2. A new query fetches the next 5 orders from that cursor.
3. The existing listener is torn down and re-attached with an expanded range that covers all pages loaded so far.

This means every order visible on screen receives real-time status updates even across multiple pages.

### 3. Atomic Transactions with `db.runTransaction()`

Used for any operation that must atomically update multiple documents. A partial write that succeeds on one document but fails on another would leave data in an inconsistent state.

Operations using transactions:

| Operation | Documents Written Atomically |
|---|---|
| Wallet top-up | `wallets/{userId}` balance + new `wallet_transactions` document |
| Order payment | `wallets/{userId}` balance deduction + new `wallet_transactions` document |
| Order cancellation refund | `orders/{orderId}` status update + `wallets/{userId}` balance credit + new `wallet_transactions` refund document |
| Rating submission | `products/{id}/ratings/{userId}` + `products/{id}/reviews/{autoId}` + `products/{id}` aggregate fields (`avgRating`, `ratingCount`, `ratingDistribution`) |

---

## Module Folder Convention

Every module under `Module/` follows the same folder structure:

```
Module/
  <ModuleName>/
    Model/
      <ModelName>.swift
    ViewModel/
      <FeatureViewModel>.swift
    View/
      <FeatureView>.swift
    Firebase/          (optional — for modules with their own service, e.g. Order, Wallet)
      <Service>.swift
```

Some older modules use `MVVM/Model`, `MVVM/ViewModel`, `MVVM/View` instead of the flat layout. Both are acceptable — use the flat layout for new modules.

---

## Logging

Use `AppLog.<category>.debug(...)` instead of `print`. The `AppLog` type provides category-scoped `Logger` instances backed by the unified logging system (`os.Logger`). Log output appears in Console.app and Xcode's console with structured metadata.

Available categories:

```swift
AppLog.auth        // Authentication events
AppLog.firestore   // Firestore reads/writes
AppLog.wallet      // Wallet operations
AppLog.order       // Order lifecycle
AppLog.ui          // View-layer events
```

---

## Analytics and Crash Reporting

`UserSession.setUser()` configures both Firebase Crashlytics and Firebase Analytics with the current user's ID and role immediately after sign-in:

```swift
Crashlytics.crashlytics().setUserID(user.id)
Crashlytics.crashlytics().setCustomValue(user.role.rawValue, forKey: "user_role")
AnalyticsService.shared.setUser(id: user.id, role: user.role.rawValue)
```

`UserSession.clearUser()` clears both identities on sign-out.

Use `AnalyticsService.shared` to log custom events. Do not call Firebase Analytics APIs directly from Views or ViewModels.
