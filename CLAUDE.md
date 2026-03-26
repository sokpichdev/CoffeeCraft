# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project — there are no CLI build scripts. Open `CoffeeCraft/CoffeeCraft.xcodeproj` in Xcode and use standard Xcode commands.

**Schemes** (in `CoffeeCraft.xcodeproj/xcshareddata/xcschemes/`):
- `CoffeeCraft-Dev` — development
- `CoffeeCraft-SIT` — system integration testing
- `CoffeeCraft-UAT` — user acceptance testing
- `CoffeeCraft` — production

Each scheme has a corresponding `GoogleService-Info.plist` for Firebase. Select the appropriate scheme before running.

## Architecture

**Pattern:** MVVM + Repository, with `@EnvironmentObject` for dependency injection.

```
View (SwiftUI)
  └─ ViewModel (@MainActor, @Published state)
       └─ Repository (protocol + Firebase implementation)
            └─ Firestore / Firebase Auth
```

**Navigation root:** `CoffeeCraftApp.swift` → `RootView` → `TabBarView`

`RootView` gates on auth state from `AuthViewModel`. `TabBarView` filters tabs by `UserRole` (`.customer` vs `.manager` — managers see an extra Dashboard tab).

### Global singletons (passed as `@EnvironmentObject` from `CoffeeCraftApp`)

| Object | Purpose |
|--------|---------|
| `UserSession.shared` | Current user, role, auth state |
| `AuthViewModel` | Auth lifecycle, session restore |
| `OrderViewModel` | Real-time orders with cursor-based pagination |
| `WalletViewModel` | Real-time wallet balance & transactions |
| `ThemeManager.shared` | Dark mode / palette; drives `preferredColorScheme` |
| `NotificationCoordinator.shared` | Deep-link routing from push notifications |

Additional singletons used directly (not injected):
- `AlertManager.shared` — global alert/error dialogs
- `ToastManager.shared` — toast notifications
- `LoaderManager.shared` — loading spinner
- `CartManager` — shopping cart with Firestore sync (injected per-scene)
- `NetworkMonitor.shared` — connectivity detection

### Module layout (`CoffeeCraft/CoffeeCraft/Module/`)

Each module follows the same folder structure: `MVVM/Model`, `MVVM/ViewModel`, `View`.

Key modules: `Auth`, `Home`, `Menu`, `Cart`, `Order`, `Wallet`, `Review`, `Account`, `AdminDashboard`, `Map`, `Notification`, `Theme`.

### Repository pattern

Protocols live in `/Repository/<Domain>/`, Firebase implementations in the same folder. Example: `AuthRepositoryProtocol` / `FirebaseAuthRepository`. ViewModels depend on protocols, not concrete Firebase types.

### Real-time data strategy

- **Snapshot listeners** — Products, Wallet balance, Wallet transactions, Inbox
- **Cursor-based pagination** — Orders (pageSize=5, live listener covers all loaded pages)
- **`db.runTransaction()`** — Wallet top-up, payment, refund (atomic writes across multiple docs)

### Custom UI (`/Custom/`)

30+ reusable SwiftUI components. Notable: `MaterialTextField` (floating label), `AsyncImageCard` (shimmer loading), `InfiniteCarousel`, `ShimmerView`, `ChipFlowLayout`, `CustomRefreshScrollView`. Prefer these over building new UI primitives.

### Extensions & utilities

- `Color+Ex.swift` — semantic color tokens (`accentPrimary`, `bgPrimary`, etc.) — always use these instead of raw colors
- `Font+Ex.swift` — custom font system
- `AppLog.swift` — structured logging; use instead of `print`
- `FirebaseKeys.swift` — all Firestore collection/field name constants — update here when schema changes

## Key data models

- **`Product`** — has `customizations: [String: [String: Double]]` for dynamic drink options (e.g. `Size → ["Large": 0.5]`)
- **`CartItem`** — holds a snapshot of `Product` plus `selections` and `extras`; `totalPrice` is computed
- **`Order`** — status flows: `Pending → Preparing → Ready → Completed`; cancellation (Pending only) triggers wallet refund
- **`Wallet`** / **`WalletTransaction`** — balance lives in `wallets/{userId}`; ledger in `wallet_transactions`

## Firestore collections

`users`, `products`, `carts`, `orders`, `wallets`, `wallet_transactions`, `branches`, `announcements`, `loyaltyCards`, `reviews`

Full schema reference: `CoffeeCraft/docs/firestore-schema.md`

## Theme system

`ThemeManager` exposes `theme` (light/dark) and `palette` (color accent). The app root uses `.id(themeManager.palette.rawValue)` to force a full SwiftUI re-render on palette change, which is intentional — don't remove it.
