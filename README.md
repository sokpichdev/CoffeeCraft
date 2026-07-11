# ☕ CoffeeCraft

<p align="center">
  <strong>A production-grade iOS coffee shop ordering app — one codebase, two roles.</strong><br/>
  <sub>Customers order and track drinks in real time; managers run the store from a full analytics dashboard.</sub>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-iOS%2017%2B-blue"/>
  <img alt="Language" src="https://img.shields.io/badge/Swift-5.9%2B-orange"/>
  <img alt="UI" src="https://img.shields.io/badge/UI-SwiftUI-1575F9"/>
  <img alt="Backend" src="https://img.shields.io/badge/Backend-Firebase-FFCA28"/>
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-MVVM%20%2B%20Repository-success"/>
  <img alt="Status" src="https://img.shields.io/badge/status-production--ready-brightgreen"/>
  <img alt="" src="https://komarev.com/ghpvc/?username=sokpichdev&color=blueviolet"/>
</p>

<p align="center">
  <a href="#getting-started">🛠 Build locally</a>
</p>

---

## Table of Contents

- [Screenshots](#screenshots)
- [Features](#features)
- [Demo](#demo)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Module Breakdown](#module-breakdown)
- [Key Data Models](#key-data-models)
- [Firestore Collections](#firestore-collections)
- [Theme System](#theme-system)
- [Navigation Flow](#navigation-flow)
- [Custom UI Components](#custom-ui-components)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Privacy & Permissions](#privacy--permissions)
- [Project Status](#project-status)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Author](#author)

---

## Screenshots

### Customer App

**Onboarding & Authentication**

| Login | Sign Up | Reset Password | Splash / Loading |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/login.png" width="190"/> | <img src="docs/screenshots/customers/signup.png" width="190"/> | <img src="docs/screenshots/customers/forget_password.png" width="190"/> | <img src="docs/screenshots/customers/loading.png" width="190"/> |

**Home & Menu**

| Home | Menu | Search | Product Detail |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/home.gif" width="190"/> | <img src="docs/screenshots/customers/menu.png" width="190"/> | <img src="docs/screenshots/customers/search_menu.png" width="190"/> | <img src="docs/screenshots/customers/product_detail.png" width="190"/> |

**Ordering & Checkout**

| Pickup / Delivery | Store Selection | Cart | Payment Method |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/pickup_delivery.png" width="190"/> | <img src="docs/screenshots/customers/store_selection.png" width="190"/> | <img src="docs/screenshots/customers/cart.png" width="190"/> | <img src="docs/screenshots/customers/payment_method.png" width="190"/> |

**Orders & Live Delivery**

| Orders | Order Detail | Live Delivery | Reviews & Ratings |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/orders.png" width="190"/> | <img src="docs/screenshots/customers/order_detail.png" width="190"/> | <img src="docs/screenshots/customers/delivery.png" width="190"/> | <img src="docs/screenshots/customers/ratings_reviews.png" width="190"/> |

**Branches, Wallet & Loyalty**

| Find a Branch | Branch Info | Wallet | Top Up |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/find_branch.png" width="190"/> | <img src="docs/screenshots/customers/branch_info.png" width="190"/> | <img src="docs/screenshots/customers/wallet.png" width="190"/> | <img src="docs/screenshots/customers/topup.png" width="190"/> |

**Account & Appearance**

| Account | Edit Profile | Shared Loyalty Cards | Settings | Color Palettes |
|:---:|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/customers/account.png" width="150"/> | <img src="docs/screenshots/customers/edit_profile.png" width="150"/> | <img src="docs/screenshots/customers/shared_cards.png" width="150"/> | <img src="docs/screenshots/customers/settings.png" width="150"/> | <img src="docs/screenshots/customers/color_pallete.png" width="150"/> |

### Manager / Admin Dashboard

**Sales & Product Analytics**

| Sales Analytics | Rating vs. Sales | Best Sellers | Product Performance |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/admin/sales_analytics.png" width="190"/> | <img src="docs/screenshots/admin/rating_sales.png" width="190"/> | <img src="docs/screenshots/admin/best_sellers.png" width="190"/> | <img src="docs/screenshots/admin/product_performance.png" width="190"/> |

**Order Analytics & Operations**

| Order Funnel | Order History | Ordering Hours | Inbox |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/admin/order_analytics_funnel.png" width="190"/> | <img src="docs/screenshots/admin/order_analytics_history.png" width="190"/> | <img src="docs/screenshots/admin/pick_ordering_hours.png" width="190"/> | <img src="docs/screenshots/admin/inbox.png" width="190"/> |

**Moderation & Users**

| Review Moderation | Users List | User Detail |
|:---:|:---:|:---:|
| <img src="docs/screenshots/admin/review_moderation.png" width="190"/> | <img src="docs/screenshots/admin/users_info.png" width="190"/> | <img src="docs/screenshots/admin/users_detail.png" width="190"/> |

---

## Features

- **Real-time order tracking** — orders move through `Pending → Preparing → Ready → Completed` with a live status listener and cursor-based pagination.
- **Live delivery on a map** — once a delivery order dispatches, a rider annotation animates along a real route with a live ETA, backed by MapKit + Firestore.
- **In-app wallet** — top-up, payment, and refund all run as atomic Firestore transactions, keeping the balance and an append-only ledger in sync.
- **Proof-of-purchase reviews** — customers can only rate products they've actually completed an order for; rating aggregates update atomically on submit.
- **Loyalty cards with shared access** — cards can be shared across multiple user accounts.
- **Manager analytics dashboard** — KPI summary, order funnel, sales trends, best sellers, and review moderation, gated behind `UserRole.manager`.
- **Theming** — light/dark appearance plus four selectable color palettes (Brown, Strawberry, Matcha, Oreo), persisted across restarts.

---

## Demo

<!-- No demo video yet. Add a short GIF/video here once one is recorded (e.g. browse menu → customize drink → checkout, or live order tracking on the map). -->

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | SwiftUI (iOS 17+) |
| Language | Swift 5.9+ |
| Architecture | MVVM + Repository |
| Backend | Firebase (Auth, Firestore, Cloud Messaging, Crashlytics, Analytics, Performance) |
| Database | Cloud Firestore |
| Authentication | Firebase Auth (Email/Password) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Maps | MapKit + CoreLocation |
| Dependencies | Swift Package Manager |
| Minimum iOS | 17.0 |
| Xcode | 15+ |

---

## Architecture

CoffeeCraft follows MVVM with a Repository layer. ViewModels never import Firebase directly — they depend only on repository protocols, and every layer depends only on the one below it.

```
View (SwiftUI)
  └─ ViewModel (@MainActor, @Published state)
       └─ Repository Protocol
            └─ Firebase Repository (Firestore / Firebase Auth)
```

### System Architecture

```mermaid
flowchart TD
    User(["👤 Customer / Manager"]) --> APP

    subgraph Presentation["🖼️ Presentation — SwiftUI"]
        APP["CoffeeCraftApp (@main)"]
        ROOT["RootView — auth gate + scene VMs"]
        TAB["TabBarView — role-filtered tabs"]
        CUST["Customer Views<br/>Home · Menu · Cart · Orders · Wallet · Map · Account"]
        MGR["Manager Views<br/>Dashboard · Analytics · Moderation"]
        APP --> ROOT --> TAB
        TAB --> CUST
        TAB --> MGR
    end

    subgraph State["🧠 State — ViewModels (@MainActor, @Published)"]
        AUTHVM[AuthViewModel]
        ORDERVM[OrderViewModel]
        WALLETVM[WalletViewModel]
        PRODVM[ProductViewModel]
        MAPVM[MapViewModel]
        DELVM[DeliveryViewModel]
        ADMINVM[Dashboard / Analytics VMs]
    end

    subgraph Domain["⚙️ Services & Repositories — protocol-backed"]
        AUTHREPO[AuthRepository]
        PRODREPO[ProductRepository]
        ORDERREPO[OrderRepository]
        WALLETSVC[WalletService]
        BRANCHREPO[BranchRepository]
        RATINGSVC[RatingService]
    end

    subgraph Backend["🔥 Firebase"]
        AUTH[(Auth)]
        FS[(Cloud Firestore)]
        FCM[(Cloud Messaging)]
        OBS[(Analytics / Crashlytics)]
    end

    CUST --> State
    MGR --> State
    State --> Domain
    Domain --> Backend
```

### Project / Module Map

Feature modules live in `CoffeeCraft/Module/`. Some are shared by all roles, others are gated by `UserRole`.

```mermaid
flowchart TB
    subgraph Shared["Shared — all roles"]
        Auth
        Home
        Menu
        Customize["Product Customization"]
        Cart
        Wallet
        MapMod["Map + Live Delivery"]
        Theme
        Notification
    end

    subgraph CustomerOnly["Customer only"]
        Order
        Review
        Favorites
        Account
    end

    subgraph ManagerOnly["Manager only — Admin Dashboard"]
        Summary["KPI Summary"]
        OrderAnalytics["Order Analytics"]
        SalesAnalytics["Sales Analytics"]
        ProductPerf["Product Performance"]
        Moderation["Review Moderation"]
    end
```

### Dependency Injection

Global singletons are injected once from `CoffeeCraftApp` via `@EnvironmentObject`; scene state is created in `RootView`; a few managers are accessed directly.

```mermaid
flowchart LR
    APP["CoffeeCraftApp (@main)"]

    subgraph Global["Injected @EnvironmentObject (global)"]
        US[UserSession.shared]
        AVM[AuthViewModel]
        OVM[OrderViewModel]
        WVM[WalletViewModel]
        TM[ThemeManager.shared]
        NC[NotificationCoordinator.shared]
    end

    subgraph Scene["Scene-scoped (created in RootView)"]
        CART[CartManager]
        PVM[ProductViewModel]
        FVM[FavoriteViewModel]
        CVM[CardViewModel]
        ANN[AnnouncementViewModel]
        IVM[InboxViewModel]
    end

    subgraph Direct["Direct-access singletons"]
        AM[AlertManager]
        TOAST[ToastManager]
        LOAD[LoaderManager]
        NM[NetworkMonitor]
        WS[WalletService]
    end

    APP --> Global
    APP --> Scene
    Global -.uses.-> Direct
    Scene -.uses.-> Direct
```

**Globally injected** (`@EnvironmentObject` from `CoffeeCraftApp`):

| Object | Purpose |
|---|---|
| `UserSession.shared` | Current user, role, auth state, Crashlytics identity |
| `AuthViewModel` | Auth lifecycle: sign-in, registration, session restore, password reset |
| `OrderViewModel` | Real-time customer orders with cursor-based pagination |
| `WalletViewModel` | Real-time wallet balance and transaction list |
| `ThemeManager.shared` | Appearance mode and color palette |
| `NotificationCoordinator.shared` | Deep-link routing from push notification taps |

**Scene-scoped** (created in `RootView`):

| Object | Purpose |
|---|---|
| `CartManager` | Shopping cart with Firestore sync, one per scene |
| `ProductViewModel` | Product catalog and CRUD |
| `FavoriteViewModel` | Wishlist management |
| `CardViewModel` | Loyalty card management |
| `AnnouncementViewModel` | Home screen announcements |
| `InboxViewModel` | Notification inbox with pagination |

**Direct-access singletons** (not injected):

| Object | Purpose |
|---|---|
| `AlertManager.shared` | Global modal alerts and error dialogs |
| `ToastManager.shared` | Transient toast notifications |
| `LoaderManager.shared` | Full-screen loading spinner |
| `NetworkMonitor.shared` | Connectivity detection |
| `WalletService.shared` | All atomic wallet mutations (top-up, payment, refund) |

### Repository Pattern

Every domain with Firebase access has a protocol in `CoffeeCraft/Repository/<Domain>/` and a Firebase implementation in the same folder:

| Protocol | Firebase Implementation |
|---|---|
| `AuthRepositoryProtocol` | `FirebaseAuthRepository` |
| `ProductRepositoryProtocol` | `FirestoreProductRepository` |
| `OrderRepositoryProtocol` | `FirestoreOrderRepository` |
| `WalletRepositoryProtocol` | `FirestoreWalletRepository` |

ViewModels receive a repository via initializer injection, defaulting to the Firebase implementation. Swap the implementation in tests without touching any ViewModel or View code.

### Order & Delivery Lifecycle

An order moves through a fixed status flow; once a delivery order is dispatched, a separate live-tracking lifecycle drives the map (powered by `DeliveryViewModel` + Firestore `deliveries/`).

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Pending: placed (wallet / cash)
    Pending --> Preparing
    Preparing --> Ready
    Ready --> Completed
    Pending --> Cancelled: cancel → atomic wallet refund
    Completed --> [*]
    Cancelled --> [*]
```

```mermaid
stateDiagram-v2
    direction LR
    [*] --> orderPlaced: Preparing your order
    orderPlaced --> riderAssigned: Rider heading to branch
    riderAssigned --> pickedUp: Rider picked up order
    pickedUp --> enRoute: On the way to you
    enRoute --> arriving: Almost there
    arriving --> delivered: Delivered
    delivered --> [*]
```

### Real-Time Data Strategy

| Strategy | Used For |
|---|---|
| Snapshot listeners | Products, wallet balance, wallet transactions, inbox notifications |
| Cursor-based pagination | Orders (pageSize = 5; the listener covers all loaded pages) |
| `db.runTransaction()` | Wallet top-up, order payment, order cancellation refund — all atomic across multiple documents |

---

## Folder Structure

```
CoffeeCraft/
├── Main/
│   └── View/
│       ├── CoffeeCraftApp.swift      # @main entry, all EnvironmentObjects injected here
│       ├── RootView.swift            # Auth gate + tab routing + scene ViewModels
│       ├── TabBarView.swift          # Custom animated tab bar, role-filtered tabs
│       ├── ContentView.swift
│       └── AppDelegate.swift         # FCM setup, push notification delegate
│
├── Module/                           # Feature modules (see Module Breakdown)
│   ├── Auth/
│   ├── Home/
│   ├── Menu/
│   ├── ProductCustomization/
│   ├── Cart/
│   ├── Order/
│   ├── Wallet/
│   ├── Review/
│   ├── Favorites/
│   ├── Map/
│   ├── Account/
│   ├── AdminDashboard/
│   ├── Profile/
│   ├── Notification/
│   ├── Theme/
│   └── Settings/
│
├── Repository/                       # Protocol + Firebase implementations
│   ├── Auth/
│   ├── Product/
│   ├── Order/
│   └── Wallet/
│
├── Custom/                           # 30+ reusable SwiftUI components
│   ├── API_UI_Components/            # AlertManager, ToastManager, LoaderManager, ShimmerView
│   ├── Scroll/                       # CustomRefreshScrollView
│   ├── MaterialTextField.swift
│   ├── AsyncImageCard.swift
│   ├── InfiniteCarousel.swift
│   ├── ChipFlowLayout.swift
│   └── ...
│
├── Extension/
│   ├── Color+Ex.swift                # Semantic color token system
│   ├── Font+Ex.swift                 # Custom font system
│   ├── View+Ex.swift
│   ├── String+Ex.swift
│   └── Double+Ex.swift
│
├── Utilize/
│   ├── UserSession.swift             # Auth + user identity state
│   ├── AppLog.swift                  # Structured logging (use instead of print)
│   ├── AnalyticsService.swift        # Firebase Analytics wrapper
│   ├── PerformanceService.swift      # Firebase Performance wrapper
│   └── Network/
│       └── NetworkMonitor.swift
│
├── Constants/
│   └── FirebaseKeys.swift            # All Firestore collection/field name constants
│
└── docs/
    ├── firestore-schema.md           # Full Firestore schema reference
    ├── architecture.md               # MVVM + Repository deep-dive
    ├── theme-system.md               # Theme and color token guide
    ├── navigation.md                 # Navigation flow and deep-link routing
    └── custom-components.md          # Custom UI component catalog
```

---

## Module Breakdown

Each module follows the folder convention `MVVM/Model`, `MVVM/ViewModel`, `View` (or the flat equivalents `Model/`, `ViewModel/`, `View/`).

### Auth

Email/password sign-up, sign-in, and password reset via Firebase Auth. On sign-up the app writes a `users/{uid}` document with name, email, role, and optional profile fields. `AuthViewModel` restores sessions on launch via `Auth.auth().currentUser`.

Key files: `AuthViewModel.swift`, `AuthView.swift`, `FirebaseAuthRepository.swift`

### Home

Landing screen with an infinite banner carousel, announcement cards, and wallet balance shortcut. `AnnouncementViewModel` listens to the `announcements` Firestore collection.

Key files: `HomeView.swift`, `AnnouncementViewModel.swift`, `InfiniteCarousel.swift`

### Menu

Product catalog grouped by category. Supports search by name, category chip filtering, and product detail with customization. Managers see add/edit/delete controls. `ProductViewModel` uses a snapshot listener so product availability updates in real time.

Key files: `MenuView.swift`, `ProductViewModel.swift`, `FirestoreProductRepository.swift`

### ProductCustomization

Dynamic drink customization sheet. `Product.customizations` is a `[String: [String: Double]]` map (e.g. `"Size" → ["Small": 0.0, "Large": 1.0]`). The sheet renders one selection group per key. Price delta is computed in `CartItem.totalPrice`.

Key files: `CustomizationView.swift`, `CustomizationOption.swift`

### Cart

Shopping cart backed by a Firestore document at `carts/{userId}`. `CartManager` encodes the full `CartItem` (including the nested `Product` snapshot) via `Firestore.Encoder` so the cart survives app restarts.

Key files: `CartManager.swift`, `CartItem.swift`

### Order

Customer-facing order list with real-time status updates and cursor-based pagination. Each order card links to a detail view showing a status timeline, pricing breakdown, and reorder button. Orders in `Pending` status can be cancelled, which triggers an atomic wallet refund. Managers see a separate `AdminOrdersView` to update order status and send FCM notifications to the customer.

Order status flow: `Pending` → `Preparing` → `Ready` → `Completed`

Key files: `OrderViewModel.swift`, `AdminOrdersViewModel.swift`, `OrderService.swift`, `Order.swift`, `OrderDetailView.swift`, `OrderReceiptView.swift`

### Wallet

In-app wallet with balance display and scrollable transaction history. Top-up is a three-step flow: Amount → Bank → Checkout. All balance mutations (top-up, payment, refund) go through `WalletService.shared` using Firestore transactions to keep the `wallets` balance and `wallet_transactions` ledger in sync atomically.

Key files: `WalletViewModel.swift`, `WalletService.swift`, `Wallet.swift`, `WalletTransaction.swift`

### Review

Proof-of-purchase verified reviews. Before a customer can rate a product, the app queries `orders` for a completed order containing that product's ID. Star ratings live at `products/{id}/ratings/{userId}` (one per user per product). Review text lives at `products/{id}/reviews/{autoId}`. `RatingService` runs a Firestore transaction on submit to atomically update `avgRating`, `ratingCount`, and `ratingDistribution` on the product document.

Key files: `RatingService.swift`, `ReviewViewModel.swift`, `UserRating.swift`, `Review.swift`

### Favorites

Wishlist backed by `users/{uid}/favorites/{productId}` subcollection documents. `FavoriteViewModel` loads favorites on launch and keeps an in-memory set for O(1) toggle checks.

Key files: `FavoriteViewModel.swift`, `FavoriteItem.swift`

### Map & Live Delivery

Store locator built on MapKit + CoreLocation showing every branch as an annotated pin, with search, filter chips, distance sorting, and an "Order from here" handoff into the menu. The branch detail sheet shows hours, amenities, staff-posted wait time, and an Apple Maps directions button. `OrderEnvironment.shared` is the cross-module hub that holds the selected branch, fulfillment mode (pickup vs. delivery), and all active delivery sessions.

The **Delivery** submodule (`Map/Delivery/`) drives real-time rider tracking: when a delivery order reaches `OnDelivery`, `DeliveryViewModel` starts a route simulation (`DeliverySimulator`), animates a rider annotation along an `MKPolyline`, computes a live ETA, and persists the rider's last position to Firestore `deliveries/{orderId}`. `DeliveryRestoreService` resumes an in-progress delivery at the correct mid-route position after an app relaunch, and multiple concurrent deliveries are tracked independently (keyed by `orderId`).

Key files: `MapView.swift`, `MapViewModel.swift`, `OrderEnvironment.swift`, `Branch.swift`, `BranchRepository.swift`, `DeliveryViewModel.swift`, `DeliverySession.swift`, `DeliveryStatus.swift`, `DeliveryRestoreService.swift`, `DeliveryMapView.swift`

### Account

Profile hub with sections for wallet balance, loyalty cards, inbox, order history, profile editing, and appearance settings. The inbox fetches paginated notifications from the `users/{uid}/notifications` subcollection and categorizes them into typed row views (order status, wallet, announcement, promotion, reward).

Key files: `AccountView.swift`, `InboxViewModel.swift`, `CardViewModel.swift`

### AdminDashboard

Manager-only tab with four sub-sections:
- **Dashboard Summary** — KPI cards (revenue today/week/month, active orders, new customers) and a live order feed
- **Order Analytics** — real-time order queue with status filter
- **Product Performance** — best sellers and analytics charts
- **Sales Analytics** — revenue over time and peak-hour heatmap
- **Review Moderation** — hide/unhide reviews per product

Key files: `DashboardHomeViewModel.swift`, `OrderAnalyticsViewModel.swift`, `ProductPerformanceViewModel.swift`, `SalesAnalyticsViewModel.swift`, `ReviewModerationViewModel.swift`

### Theme

Manages appearance mode (system/light/dark) and color palette (Brown, Strawberry, Matcha, Oreo) persisted via `@AppStorage`. See `docs/theme-system.md` for the full token reference.

Key files: `ThemeManager.swift`, `AppTheme.swift`, `AppearanceSettingsView.swift`

### Notification

`AppDelegate` registers for push notifications and forwards FCM tokens to Firestore at `users/{uid}/fcmTokens/{deviceId}`. `NotificationCoordinator` receives tap callbacks and sets a flag that `RootView` observes to navigate to the Orders tab.

Key files: `AppDelegate.swift`, `NotificationCoordinator.swift`

---

## Key Data Models

### User

```swift
struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var role: UserRole          // .customer | .manager
    var phoneNumber: String?
    var gender: String?
    var dateOfBirth: Date?
    var city: String?
}
```

### Product

```swift
struct Product: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var category: String
    var available: Bool
    var customizations: [String: [String: Double]]?  // e.g. "Size" → ["Large": 1.0]
    var avgRating: Double?
    var ratingCount: Int?
    var ratingDistribution: [String: Int]?           // keys "1".."5"
}
```

### CartItem

```swift
struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product          // full snapshot at add-to-cart time
    let selections: [String: String]  // e.g. ["Size": "Large"]
    let extras: [String]
    var quantity: Int
    var totalPrice: Double        // computed from base price + option deltas * quantity
}
```

### Order

Stored in `orders/{autoId}`. Key fields:

| Field | Type | Notes |
|---|---|---|
| `userId` | String | Firebase Auth UID |
| `orderId` | Int | Sequential display number |
| `items` | [CartItemData] | Lightweight snapshot — name, price, selections, extras |
| `totalPrice` | Double | |
| `status` | String | "Pending" / "Preparing" / "Ready" / "Completed" |
| `timestamp` | Date | |
| `paymentMethod` | String? | "wallet" or "cash" |
| `walletAmountPaid` | Double? | Wallet amount deducted, used for refund |
| `branchId` | String? | Branch document ID |
| `productIds` | [String]? | Flat list used for proof-of-purchase queries |

### Wallet

```swift
struct Wallet: Identifiable, Codable {
    var id: String?           // = userId
    var balance: Double
    let currency: String      // "USD"
    var totalTopUp: Double
    var totalSpent: Double
    let createdAt: Date
    var updatedAt: Date
}
```

### WalletTransaction

Append-only ledger document. `amount` is positive for credits (top-up, refund, reward) and negative for debits (payment).

| Field | Type | Notes |
|---|---|---|
| `userId` | String | |
| `type` | String | "topup" / "payment" / "refund" / "reward" |
| `amount` | Double | + credit, - debit |
| `balanceBefore` | Double | Snapshot for auditability |
| `balanceAfter` | Double | Snapshot for auditability |
| `description` | String | Human-readable label |
| `referenceId` | String? | orderId for payment/refund types |
| `timestamp` | Date | |

### LoyaltyCard

```swift
struct LoyaltyCard: Identifiable, Codable {
    var id: String?
    let cardNumber: String
    let ownerId: String
    let ownerName: String
    let memberSince: String
    var points: Int
    let createdAt: Date
    var sharedWith: [String]   // array of userIds with shared access
}
```

---

## Firestore Collections

For the full field-level schema with example documents see `CoffeeCraft/CoffeeCraft/CoffeeCraft/docs/firestore-schema.md`.

| Collection | Document ID | Purpose |
|---|---|---|
| `users` | Firebase Auth UID | User profile, role, optional details |
| `products` | Auto ID | Product catalog with customizations and rating aggregates |
| `products/{id}/ratings` | userId | One rating per user per product (proof of purchase, star score) |
| `products/{id}/reviews` | Auto ID | Optional review text linked to a rating |
| `carts` | userId | Active shopping cart (full CartItem snapshots) |
| `orders` | Auto ID | Placed orders with status, items, payment details |
| `wallets` | userId | Wallet balance and lifetime totals |
| `wallet_transactions` | Auto ID | Append-only balance ledger |
| `branches` | Auto ID | Physical store locations with coordinates, hours, amenities, wait time |
| `deliveries` | orderId | Live delivery session: rider position, status, ETA, route endpoints |
| `announcements` | Auto ID | Home screen announcement cards |
| `loyaltyCards` | Auto ID | Loyalty cards, ownership, shared access, points |

---

## Theme System

`ThemeManager.shared` manages two independent settings:

- **Appearance mode** (`AppTheme`): `.system`, `.light`, `.dark` — maps to SwiftUI `ColorScheme`
- **Color palette** (`ColorPalette`): `.brown`, `.strawberry`, `.matcha`, `.oreo`

Both are persisted with `@AppStorage` and survive app restarts.

### Semantic Color Tokens

Always use these tokens instead of raw hex colors or asset catalog names:

| Token | Purpose |
|---|---|
| `Color.bgPrimary` | Main app background |
| `Color.bgSecondary` | Grouped list section background |
| `Color.surfacePrimary` | Card and sheet surfaces |
| `Color.surfaceSub` | Nested rows, chips, tag backgrounds |
| `Color.borderColor` | Dividers, card strokes, input borders |
| `Color.textPrimary` | Body copy and titles |
| `Color.textSecondary` | Subtitles and secondary labels |
| `Color.textMuted` | Placeholders, timestamps, captions |
| `Color.accentPrimary` | Primary CTA buttons, tab highlights, active states |
| `Color.accentGold` | Rewards, points, premium CTAs |

All tokens call `ThemeManager.shared.palette.dynamicColor(...)`, which uses `UIColor(dynamicProvider:)` to handle light/dark switching automatically.

### Palette Re-Render

`CoffeeCraftApp` applies `.id(themeManager.palette.rawValue)` to the root view. This forces a full SwiftUI re-render when the palette changes, ensuring every `Color.accentPrimary` call picks up the new palette. Do not remove this modifier.

See `docs/theme-system.md` for a complete palette and token reference.

---

## Navigation Flow

```mermaid
flowchart TD
    Launch([App Launch]) --> Restore{session.isRestoring?}
    Restore -- yes --> Loader[CoffeeLoaderView]
    Restore -- no --> AuthGate{Authenticated?}
    Loader --> AuthGate
    AuthGate -- no --> Login[AuthView — sign in / sign up / reset]
    AuthGate -- yes --> Role{UserRole?}
    Login --> Role

    Role -- customer --> CTabs["Tab bar (4): Home · Menu · Orders · Account"]
    Role -- manager --> MTabs["Tab bar (5): Dashboard · Home · Menu · Orders · Account"]

    CTabs --> Home[HomeView]
    CTabs --> Menu[MenuView]
    CTabs --> Orders[OrdersView]
    CTabs --> Account[AccountView]

    MTabs --> Dash[AdminDashboardHomeView]
    MTabs --> MenuM["MenuView + edit controls"]
    MTabs --> OrdersM[AdminOrdersView]

    Push[/Push notification tap/] -. NotificationCoordinator .-> Orders
```

The `Tab` enum has five cases: `dashboard`, `home`, `menu`, `orders`, `profile`. `Tab.visible(for:)` filters out `.dashboard` for customer role, so the tab bar shows 4 tabs for customers and 5 for managers.

Push notification taps route through `NotificationCoordinator`. When the coordinator sets `shouldNavigateToOrders`, `RootView` switches `selectedTab` to `.orders`.

---

## Custom UI Components

All reusable components live in `CoffeeCraft/Custom/`. Prefer these over building new primitives.

### Input

| Component | Description |
|---|---|
| `MaterialTextField` | Floating-label text field with validation state |
| `CustomTextField1` | Extended field with leading icon |
| `CustomSecureField` | Password field with show/hide toggle |
| `CustomNumberField` | Numeric-only input |

### Selection

| Component | Description |
|---|---|
| `CustomSegmentedControl` | Styled segment picker matching app theme |
| `CustomSingleSelectionView` | Radio-button-style grid for single selection |
| `CustomMultipleSelectionView` | Checkbox-style grid for multi-select |
| `ChipFlowLayout` | Wrapping chip layout for tag/filter lists |
| `PickerSheetView` | Bottom sheet with list picker |

### Media

| Component | Description |
|---|---|
| `AsyncImageCard` | Async image with built-in shimmer skeleton while loading |
| `InfiniteCarousel` | Auto-scrolling banner carousel with manual page control |
| `ShimmerView` | Standalone shimmer/skeleton effect for loading states |
| `WebView` | WKWebView wrapper for in-app web content |

### Feedback

| Component | Description |
|---|---|
| `AlertManager` | Global alert/error dialog system (call `AlertManager.shared.showSuccess(...)`) |
| `ToastManager` | Transient toast notifications (call `ToastManager.shared.show(...)`) |
| `LoaderManager` | Full-screen loading spinner overlay |
| `OfflineBannerModifier` | Sticky banner shown when `NetworkMonitor` detects no connectivity |
| `ComingSoonView` | Placeholder for features not yet implemented |

### Layout and Navigation

| Component | Description |
|---|---|
| `CustomRefreshScrollView` | ScrollView with pull-to-refresh |
| `ActionCardButton` | Large tappable card for primary actions |
| `ToolBarButton` | Consistent toolbar/navigation bar button |
| `MinimumLoadingTime` | Ensures a loading state shows for at least N milliseconds |

---

## Getting Started

### Requirements

- macOS with Xcode 15 or later
- iOS 17+ simulator or device
- A Firebase project (Auth + Firestore + Cloud Messaging enabled)

### Clone

```bash
git clone https://github.com/sokpichdev/CoffeeCraft.git
cd CoffeeCraft
```

### Configuration

The project has four Xcode schemes, each pointing to a separate Firebase project via its own `GoogleService-Info.plist`:

| Scheme | Purpose | Plist |
|---|---|---|
| `CoffeeCraft-Dev` | Local development | `GoogleService-Info-Dev.plist` |
| `CoffeeCraft-SIT` | System integration testing | `GoogleService-Info-SIT.plist` |
| `CoffeeCraft-UAT` | User acceptance testing | `GoogleService-Info-UAT.plist` |
| `CoffeeCraft` | Production | `GoogleService-Info.plist` |

Scheme files live in `CoffeeCraft.xcodeproj/xcshareddata/xcschemes/`.

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a new project.
2. Add an iOS app with your bundle identifier.
3. Enable **Email/Password** authentication under Authentication > Sign-in method.
4. Create a **Cloud Firestore** database (start in production mode for real deployments; test mode is fine for local dev).
5. Enable **Firebase Cloud Messaging** under Cloud Messaging.
6. Download `GoogleService-Info.plist` from the project settings, rename it to `GoogleService-Info-Dev.plist`, and place it in `CoffeeCraft/CoffeeCraft/`. Repeat for each environment you need (SIT, UAT, production).

If you only have one Firebase project for development, copy the same plist as `GoogleService-Info-Dev.plist` and select the `CoffeeCraft-Dev` scheme before building.

For development-only Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Update these rules before deploying to production.

### Install dependencies

```bash
open CoffeeCraft/CoffeeCraft.xcodeproj
```

Xcode automatically resolves the required Firebase SPM packages on first open:

- `FirebaseAuth`
- `FirebaseFirestore`
- `FirebaseMessaging`
- `FirebaseCrashlytics`
- `FirebaseAnalytics`
- `FirebasePerformance`

### Run

1. Select the `CoffeeCraft-Dev` scheme from the scheme picker in the toolbar.
2. Choose an iOS 17 simulator or physical device.
3. Press `Cmd+R` to build and run.

### Seeding sample data

1. Create a manager account (see Creating Test Accounts below).
2. Go to the Menu tab.
3. Tap the seed button in the manager controls (visible only in the Dev scheme).
4. This writes sample products and branch documents to Firestore.

### Creating test accounts

Use the Register screen in the app to create accounts. Set the role field to the desired role:

**Customer account**

| Field | Value |
|---|---|
| Name | Test Customer |
| Email | customer@test.com |
| Password | Test123! |
| Role | Customer |

**Manager account**

| Field | Value |
|---|---|
| Name | Test Manager |
| Email | manager@test.com |
| Password | Test123! |
| Role | Manager |

Managers will see a Dashboard tab and the product management controls in the Menu tab.

---

## Testing

There is no automated test suite or CI pipeline yet. Verification today is manual: build and run each scheme, then exercise the customer and manager flows using the test accounts above (see Roadmap).

---

## Privacy & Permissions

| Permission | Why we need it | When we ask |
|---|---|---|
| Location (`NSLocationWhenInUseUsageDescription`) | Find nearby branches and support delivery | When using the Map / branch finder |

No dedicated privacy policy document exists yet. Firebase Analytics and Crashlytics are enabled for the app; no other third-party data sharing is configured.

---

## Project Status

✅ Production-ready — Version 1.0, last updated June 2026. Customer and Manager experiences, real-time
order tracking, wallet, loyalty cards, reviews, and the admin analytics dashboard are all shipped.

---

## Roadmap

- [ ] Add an automated test suite (unit + UI tests)
- [ ] Add a CI pipeline (build + test on every PR)
- [ ] Choose and add a LICENSE
- [ ] Push notifications for order status (beyond current FCM plumbing)

Have an idea? Open a discussion or issue on the repository.

---

## Contributing

1. Fork the repository.
2. Create a feature branch from `main`: `git checkout -b feature/your-feature-name`
3. Follow the MVVM + Repository pattern. New data sources should have a protocol before a Firebase implementation.
4. Use `Color.accentPrimary`, `Color.bgPrimary`, and the other semantic tokens — never raw hex or system colors.
5. Use `AppLog.<category>.debug(...)` instead of `print`.
6. Add doc comments to all public types and functions in `Services/`, `Repository/`, and `ViewModel/` files.
7. Open a pull request against `main`.

---

## Security

There is no dedicated security disclosure process or `SECURITY.md` yet. If you find a vulnerability, please email pichsok016@gmail.com directly rather than opening a public issue.

---

## License

No license file exists in this repository yet. Until one is added, all rights are reserved by default — do not treat this as open source.

---

## Acknowledgments

- [Firebase](https://firebase.google.com) — Auth, Firestore, Cloud Messaging, Crashlytics, Analytics, Performance
- Apple's MapKit + CoreLocation frameworks — store locator and live delivery tracking

---

## Author

**Sok Pich** — iOS Developer
Contact: pichsok016@gmail.com
Status: Production-ready · Version 1.0 · Last updated June 2026
