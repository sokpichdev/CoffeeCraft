# ☕ CoffeeCraft

> A full-featured iOS coffee shop app built with **SwiftUI** and **Firebase** — covering ordering, wallet payments, loyalty points, branch mapping, push notifications, and admin order management.

-----

## Table of Contents

- [Overview](#overview)
- [Screenshots & Features](#screenshots--features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Modules](#modules)
  - [Auth](#auth)
  - [Home](#home)
  - [Menu](#menu)
  - [Product Customization](#product-customization)
  - [Cart](#cart)
  - [Order (Customer)](#order--customer)
  - [Order (Admin)](#order--admin)
  - [Wallet](#wallet)
  - [Map & Branches](#map--branches)
  - [Favorites](#favorites)
  - [Account & Profile](#account--profile)
  - [Notifications & Inbox](#notifications--inbox)
  - [Theme System](#theme-system)
  - [Settings](#settings)
- [User Roles](#user-roles)
- [Firestore Schema](#firestore-schema)
- [Custom UI Component Library](#custom-ui-component-library)
- [Environment Configuration](#environment-configuration)
- [Roadmap](#roadmap)
- [Getting Started](#getting-started)

-----

## Overview

CoffeeCraft is an iOS application simulating a real-world coffee shop experience with two distinct user roles — **Customer** and **Manager**. Customers can browse the menu, customize drinks, pay via an in-app wallet, track their orders in real time, earn loyalty points, and find nearby branches. Managers get a full admin panel to manage products, update order statuses, and push notifications to customers.

The app is built as a portfolio project demonstrating production-grade iOS patterns: MVVM architecture, real-time Firestore listeners, Firebase Cloud Messaging, custom SwiftUI navigation, theming, and a rich reusable component library.

-----

## Architecture

```
CoffeeCraft
├── MVVM (Model – View – ViewModel)
├── Singleton Services   (UserSession, ThemeManager, WalletService, FCMTokenService)
├── Environment Objects  (shared state injected via SwiftUI environment)
├── Real-time Listeners  (Firestore addSnapshotListener for orders, wallet)
└── Custom Navigation    (PushLink + pushScreen environment key — replaces NavigationStack)
```

**Pattern highlights:**

- `@MainActor` ViewModels for safe UI updates
- `@DocumentID` Firestore decoding on all models
- Singleton + `@EnvironmentObject` hybrid for global state
- `defer { isLoading = false }` pattern for consistent loading state cleanup
- Firestore transactions for atomic wallet operations

-----

## Tech Stack

|Layer             |Technology                                    |
|------------------|----------------------------------------------|
|UI Framework      |SwiftUI                                       |
|Backend           |Firebase (Firestore, Auth, FCM)               |
|Database          |Cloud Firestore                               |
|Authentication    |Firebase Auth (Email/Password)                |
|Push Notifications|Firebase Cloud Messaging (FCM)                |
|Maps              |MapKit + CoreLocation                         |
|Image Loading     |Async `AsyncImage` with custom caching wrapper|
|State Management  |MVVM + `@EnvironmentObject` + `@StateObject`  |
|Persistence       |`@AppStorage` (theme, preferences)            |
|Networking        |Native URLSession (image loading)             |
|Minimum iOS       |iOS 17+                                       |
|Language          |Swift 5.9+                                    |

-----

## Project Structure

```
CoffeeCraft/
├── Main/
│   ├── View/
│   │   ├── CoffeeCraftApp.swift       # App entry point, Firebase config
│   │   ├── RootView.swift             # Auth gate, environment injection
│   │   ├── ContentView.swift
│   │   ├── TabBarView.swift           # Custom animated tab bar
│   │   └── AppDelegate.swift          # FCM delegate setup
│   └── ViewModel/
│       └── MainViewModel.swift
├── Module/
│   ├── Auth/                          # Register, Login, Logout
│   ├── Home/                          # Banner carousel, announcements, quick order
│   ├── Menu/                          # Product listing, search, categories
│   ├── ProductCustomization/          # Drink customization options
│   ├── Cart/                          # Cart management, checkout
│   ├── Order/                         # Customer & admin order flows
│   ├── Wallet/                        # Balance, top-up, transactions
│   ├── Map/                           # Branch finder, MapKit integration
│   ├── Favorites/                     # Wishlist / saved drinks
│   ├── Account/                       # Profile, inbox, loyalty card
│   ├── Profile/                       # Edit profile details
│   ├── Notification/                  # FCM token service, coordinator
│   ├── Theme/                         # Dark mode, color palettes
│   └── Settings/                      # App settings, appearance
├── Custom/
│   ├── Navigation/                    # PushLink, custom nav bar
│   ├── API_UI_Components/             # Alert, Toast managers
│   ├── MaterialTextField.swift
│   ├── InfiniteCarousel.swift
│   ├── ChipFlowLayout.swift
│   └── ... (30+ reusable components)
├── Extension/
│   ├── Color+Ex.swift                 # Semantic color tokens
│   ├── View+Ex.swift
│   ├── String+Ex.swift
│   └── Fonts/                         # Custom font assets
├── Constants/
│   └── Constants.swift                # Firebase environment enum
├── Utilize/
│   ├── UserSession.swift              # Singleton session manager
│   ├── AppLog.swift                   # Structured logging by subsystem
│   └── Network/                       # Network monitor
└── docs/
    ├── FeaturePlanning.md
    └── firestore-schema.md
```

-----

## Modules

### Auth

**Files:** `Module/Auth/`

Handles the full authentication lifecycle using Firebase Email/Password auth.

**Features:**

- Register with name, email, password, and role selection (Customer / Manager)
- Login with email & password
- Password reset via Firebase `sendPasswordReset`
- FCM token registration on login — stored under `users/{uid}/fcmTokens/{deviceId}`
- Real-time form field validation with inline error states (`FieldValidation`)
- `UserSession.shared` singleton updates on auth state change

**Key files:**

- `AuthViewModel.swift` — all auth logic, `@MainActor`
- `AuthView.swift` — login/register screen with animated transitions
- `UserSession.swift` — global session state (`isLoggedIn`, `userId`, `userRole`)

-----

### Home

**Files:** `Module/Home/`

The app’s landing screen after login.

**Features:**

- **Infinite banner carousel** — auto-scrolling, sourced from the `announcements` collection (up to 4 images)
- **Greeting card** — time-aware greeting (morning/afternoon/evening), CC wallet balance pill, loyalty points pill, Top Up shortcut
- **Quick order buttons** — Pickup (navigates to Menu), Delivery (Coming Soon placeholder)
- **Announcements section** — card list with detail view, “See All” navigation, shimmer loading states
- Pull-to-refresh via `CustomRefreshScrollView`

**Key files:**

- `HomeView.swift` — main view with all sections
- `AnnouncementViewModel.swift` — Firestore fetch with `isAnnouncementsFetched` guard
- `AnnouncementCardView.swift`, `AnnouncementDetailView.swift`

-----

### Menu

**Files:** `Module/Menu/`

Product browsing for customers; product management for managers.

**Customer features:**

- Product grid/list with async image loading
- Category filter chips (e.g. Coffee, Tea, Espresso, Latte)
- Search by product name
- Product detail screen with description, price, customizations
- Add to cart with selected customizations

**Manager (admin) features:**

- Create new product (name, description, price, image URL, category, availability)
- Edit existing product
- Remove product
- Product seeder utility (`ProductSeeder.swift`) for populating sample data

**Key files:**

- `ProductViewModel.swift` — CRUD operations on `products` collection
- `MenuView.swift` — role-aware view (customer vs manager)
- `Product.swift` — model with optional `customizations: [String: [String: Double]]`

-----

### Product Customization

**Files:** `Module/ProductCustomization/`

Admin tool for defining drink customization options that customers select when adding to cart.

**Features:**

- Customization categories (e.g. Size, Milk, Sugar Level, Temperature)
- Options per category with optional price adjustments
- Customization library sheet for reusable option sets
- `CustomizationSeeder.swift` for seeding default options
- Visual category cards with option rows in admin editor

**Key files:**

- `CustomizationViewModel.swift`
- `CustomizationView.swift` — the customer-facing picker sheet
- `CustomizationLibrarySheet.swift` — admin reuse panel

-----

### Cart

**Files:** `Module/Cart/`

Manages the customer’s active cart with Firestore persistence.

**Features:**

- Add items with customization selections and extras
- Remove individual items
- Quantity-aware line items
- Cart persisted to Firestore under `carts/{userId}` (encoded with `Firestore.Encoder`)
- Checkout flow with payment method selection (Wallet / Cash)
- Order summary screen before confirming
- `CartManager` — `ObservableObject` singleton managing local + remote cart state

**Key files:**

- `CartManager.swift` — `loadCartFromFirestore`, `saveCartToFirestore`, `checkout`
- `CartItem.swift` — full product + selections model
- `CartItemData.swift` — lightweight snapshot stored in orders

-----

### Order — Customer

**Files:** `Module/Order/`

Full order lifecycle view for customers.

**Features:**

- **Order listing** — all past orders with status badges, real-time updates
- **Order detail screen**
  - Order header (ID, timestamp, branch name)
  - Status timeline — visual step tracker (Pending → Preparing → Ready → Completed)
  - Items card with customizations and extras
  - Pricing card with payment method and wallet amount paid
  - Receipt view (shareable bottom sheet)
- **Reorder** — re-adds all items from a past order back to the cart (`ReorderManager`)
- **Cancel order** — only allowed when status is `Pending`
  - Wallet refund automatically issued if paid via wallet (`WalletService.shared.refund`)
  - Toast confirmation with refund amount shown
- Real-time status listener via `addSnapshotListener` with haptic feedback on status change

**Key files:**

- `OrderDetailViewModel.swift` — `cancelOrder()`, `canCancel`, `startListening()`
- `OrderDetailView.swift`
- `StatusTimelineView.swift`
- `OrderReceiptView.swift`

-----

### Order — Admin

**Files:** `Module/Order/OrderListing/`

Manager’s order management panel.

**Features:**

- Real-time feed of all orders across all customers
- Update order status (Pending → Preparing → Ready → Completed)
- Push notification to customer when order status changes (`FCMTokenService`)
- `AdminOrdersViewModel` — listens to entire `orders` collection

**Key files:**

- `AdminOrdersView.swift`
- `AdminOrdersViewModel.swift`
- `OrderService.swift` — `placeOrder`, status update logic

-----

### Wallet

**Files:** `Module/Wallet/`

In-app digital wallet for paying orders and managing balance.

**Features:**

- **Balance card** — live balance display with shimmer while loading
- **Transaction history** — filterable list (All / Top-up / Payment / Refund)
- **Top-up flow** — 3-step wizard:
1. Select amount (preset pills or custom input)
1. Select bank
1. Confirm checkout
- **Wallet payment** at checkout — deducted atomically via Firestore transaction
- **Refund** — automatically triggered on order cancellation
- `WalletService` — `topUp`, `deduct`, `refund` all use Firestore transactions to prevent race conditions
- `WalletTransactionType` — `topUp`, `payment`, `refund`

**Key files:**

- `WalletService.swift` — all financial operations with Firestore transactions
- `WalletViewModel.swift` — `@Published balance`, `transactions`, `isLoading`
- `WalletView.swift` — balance + transaction list
- `TopUpView.swift` — multi-step top-up wizard

-----

### Map & Branches

**Files:** `Module/Map/`

Branch finder with MapKit integration.

**Features:**

- Interactive map with custom branch annotations (`BranchAnnotationView`)
- Branch list view with distance sorting
- **Branch detail sheet** — name, address, phone, opening hours, amenities chips, wait time
- **Wait time editor** — managers can set estimated wait time per branch
- Branch filters (open now, amenities)
- Location permission handling with fallback `MapPermissionDeniedView`
- `BranchRepository` — Firestore fetch with real-time listener
- `BranchSeeder` — seeds sample branch data
- `MapAnalytics` — tracks branch view events

**Key files:**

- `MapViewModel.swift`
- `MapView.swift` — MapKit `Map` with annotations
- `BranchDetailSheet.swift` — slide-up sheet
- `Branch.swift` — `CLLocationCoordinate2D` computed from lat/lng

-----

### Favorites

**Files:** `Module/Favorites/`

Wishlist / saved drinks for quick access.

**Features:**

- Toggle favorite on any product from the menu or product detail
- Favorites persisted per user in Firestore
- `FavoriteView` — list of favorited products with navigation to detail
- `FavoriteViewModel` — `addFavorite`, `removeFavorite`, `isFavorite` helpers

-----

### Account & Profile

**Files:** `Module/Account/`, `Module/Profile/`

Central hub for the logged-in customer.

**Account sections:**

- Profile header (avatar initial, name, email)
- Wallet balance shortcut → `WalletView`
- Loyalty card with points balance
- Personal info shortcut → `ProfileEditView`
- Order history shortcut → `OrdersView`
- Inbox (notification history)
- Settings shortcut
- App version footer

**Profile edit:**

- Name, email, phone number, gender, date of birth, city
- Change password flow

**Inbox:**

- Filterable notification history (All / Orders / Promotions / Announcements / Rewards)
- Typed notification rows: `OrderStatusNotificationRow`, `PromotionNotificationRow`, `AnnouncementNotificationRow`, `RewardNotificationRow`
- `InboxViewModel` with Firestore fetch

**Key files:**

- `AccountView.swift`
- `InboxView.swift`, `InboxViewModel.swift`
- `ProfileEditView.swift`

-----

### Notifications & Inbox

**Files:** `Module/Notification/`

Firebase Cloud Messaging integration for push notifications.

**Features:**

- FCM token registration on login, stored per device under `users/{uid}/fcmTokens/{deviceId}`
- Admin triggers push when order status updates
- `NotificationCoordinator` — `ObservableObject` singleton
  - `selectedOrderId` — deep-links notification tap to correct order detail
  - `shouldNavigateToOrders` — drives tab navigation on notification tap
- Notification history persisted in Firestore, displayed in Inbox

**Key files:**

- `FCMTokenService.swift` — token registration and storage
- `NotificationCoordinator.swift` — navigation state driven by notification tap

-----

### Theme System

**Files:** `Module/Theme/`

Full app-wide theming with appearance mode and color palette switching.

**Appearance modes** (persisted via `@AppStorage`):

- System (follows device setting)
- Light
- Dark

**Color palettes** (4 presets):

|Palette   |Emoji|Description                  |
|----------|-----|-----------------------------|
|Brown     |☕    |Warm espresso tones (default)|
|Strawberry|🍓    |Soft rose & berry            |
|Matcha    |🍵    |Fresh sage & green           |
|Oreo      |🖤    |Clean black & white          |

Each palette defines a full set of semantic color tokens (`bgPrimary`, `bgSecondary`, `surfacePrimary`, `surfaceSub`, `borderColor`, `textPrimary`, `textSecondary`, `accentPrimary`, `accentGold`) for both light and dark mode. All colors in the app reference semantic tokens — swapping palette instantly recolors the entire UI.

**Key files:**

- `ThemeManager.swift` — `shared` singleton, `@AppStorage` backed
- `ColorPalette.swift` — `PaletteTokens` struct per palette
- `AppTheme.swift` — appearance mode enum
- `ColorThemePickerView.swift` — visual 2-column grid picker
- `AppearanceSettingsView.swift` — light/dark/system selector

-----

### Settings

**Files:** `Module/Settings/`

App configuration screen accessible from the Account tab.

**Available settings:**

- Account Settings (navigation to profile edit)
- Face ID & PIN (UI placeholder)
- Appearance (dark mode / light mode / system)
- Color Theme (palette picker)
- Logout

-----

## User Roles

|Role      |Access                                                                      |
|----------|----------------------------------------------------------------------------|
|`customer`|Browse menu, cart, checkout, orders, wallet, favorites, map, profile        |
|`manager` |All customer access + product CRUD, admin order management, wait time editor|

Role is stored in Firestore under `users/{uid}.role` and read into `UserSession.shared.userRole` at login. The `RootView` uses the role to switch between customer and manager versions of `MenuView`, `OrdersView`, etc.

-----

## Firestore Schema

### `users/{uid}`

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "role": "customer",
  "phoneNumber": "+1 555 000 0000",
  "gender": "Female",
  "dateOfBirth": "<Timestamp>",
  "city": "Bangkok",
  "fcmTokens": {
    "<deviceId>": "<FCM token string>"
  }
}
```

### `products/{productId}`

```json
{
  "name": "Cappuccino",
  "description": "A classic Italian coffee with steamed milk foam.",
  "price": 3.5,
  "imageURL": "https://...",
  "category": "Coffee",
  "available": true,
  "customizations": {
    "Size": { "Small": 0.0, "Medium": 0.5, "Large": 1.0 },
    "Milk": { "Whole": 0.0, "Oat": 0.5 }
  }
}
```

### `carts/{userId}`

```json
{
  "items": [
    {
      "id": "<UUID>",
      "product": { "id": "...", "name": "Espresso", "price": 2.0, "..." },
      "selections": { "Size": "Small" },
      "extras": []
    }
  ]
}
```

### `orders/{orderId}`

```json
{
  "userId": "<UID>",
  "orderId": 1024,
  "timestamp": "<Timestamp>",
  "totalPrice": 12.00,
  "status": "Pending",
  "paymentMethod": "wallet",
  "walletAmountPaid": 12.00,
  "branchId": "<branchId>",
  "branchName": "CoffeeCraft Central",
  "items": [
    {
      "productId": "...",
      "name": "Cappuccino",
      "price": 4.0,
      "quantity": 2,
      "selections": { "Size": "Large" },
      "extras": ["Whip"],
      "imageURL": "https://..."
    }
  ]
}
```

**Order statuses:** `Pending` → `Preparing` → `Ready` → `Completed` | `Cancelled`

### `wallets/{userId}`

```json
{
  "balance": 45.50,
  "transactions": [
    {
      "id": "<UUID>",
      "type": "topUp",
      "amount": 20.00,
      "timestamp": "<Timestamp>",
      "orderId": null
    }
  ]
}
```

### `branches/{branchId}`

```json
{
  "name": "CoffeeCraft Central",
  "address": "123 Main Street",
  "latitude": 13.756,
  "longitude": 100.502,
  "phone": "+66 2 000 0000",
  "openingHours": "07:00 – 22:00",
  "isOpen": true,
  "amenities": ["Wi-Fi", "Parking", "Power Outlets"],
  "imageURL": "https://...",
  "estimatedWaitMinutes": 5
}
```

### `announcements/{announcementId}`

```json
{
  "title": "Buy 2 Get 1 Free",
  "body": "This weekend only...",
  "imageName": "https://...",
  "createdAt": "<Timestamp>"
}
```

-----

## Custom UI Component Library

CoffeeCraft ships with an extensive reusable component library in `Custom/`:

|Component                    |Description                                                |
|-----------------------------|-----------------------------------------------------------|
|`MaterialTextField`          |Animated floating-label text field with validation states  |
|`CustomTextField1`           |Extended text field with icon and error display            |
|`InfiniteCarousel`           |Auto-scrolling infinite image carousel                     |
|`ChipFlowLayout`             |Wrapping chip row for categories and filters               |
|`CustomSegmentedControl`     |Styled segmented picker                                    |
|`CustomMultipleSelectionView`|Multi-select option grid                                   |
|`CustomSingleSelectionView`  |Single-select option grid                                  |
|`AsyncImageCard`             |Async image with shimmer placeholder and corner radius     |
|`ActionCardButton`           |Large tappable card with icon and label                    |
|`ShimmerView`                |Skeleton shimmer loading placeholder                       |
|`ComingSoonView`             |Placeholder screen for unbuilt features                    |
|`PickerSheetView`            |Bottom sheet picker                                        |
|`WebView`                    |Embedded `WKWebView` wrapper                               |
|`AlertManager`               |Global alert singleton (warning, error, confirm)           |
|`ToastManager`               |Global toast notifications (top / bottom)                  |
|`PushLink`                   |Custom navigation link using `pushScreen` environment      |
|`CustomNavigationBar`        |Bespoke nav bar with leading/trailing toolbar buttons      |
|`CustomRefreshScrollView`    |Pull-to-refresh scroll view with configurable loader offset|
|`MinimumLoadingTime`         |Ensures loaders display for a minimum duration             |

-----

## Environment Configuration

The app supports multiple Firebase environments via compiler flags:

```swift
enum FirebaseEnvironment { case dev, sit, uat, prod }
```

Set the active scheme in Xcode:

- `Dev` — development Firebase project
- `SIT` — system integration testing
- `UAT` — user acceptance testing
- `Prod` — production

The `GoogleService-Info-Dev.plist` is included for the dev environment. Add `GoogleService-Info.plist` variants per environment and configure the active scheme’s build settings accordingly.

-----

## Roadmap

### ✅ Completed

|Feature                                  |Module              |
|-----------------------------------------|--------------------|
|Register / Login / Logout                |Auth                |
|Product CRUD (admin)                     |Menu                |
|Product browsing & detail                |Menu                |
|Cart management & checkout               |Cart                |
|Wallet (balance, top-up, payment, refund)|Wallet              |
|Order listing & detail (customer)        |Order               |
|Order management (admin)                 |Order               |
|Cancel order with wallet refund          |Order               |
|Reorder                                  |Order               |
|Order receipt view                       |Order               |
|Status timeline                          |Order               |
|Real-time order push notifications       |Notification        |
|Favorites / Wishlist                     |Favorites           |
|Loyalty points display                   |Account             |
|Branch map & detail                      |Map                 |
|Edit profile                             |Profile             |
|Dark mode + color themes                 |Theme               |
|Inbox (notification history)             |Account             |
|Announcements                            |Home                |
|Product customization editor             |ProductCustomization|

### 🔜 Planned

|Feature                                     |Priority|Notes                                          |
|--------------------------------------------|--------|-----------------------------------------------|
|Product ratings (1–5 stars)                 |High    |Firestore transaction, incremental avg         |
|Customer reviews & comments                 |High    |Sub-collection `reviews/{reviewId}`, pagination|
|Product availability badge                  |Medium  |`isAvailable` bool + admin toggle              |
|Home: Featured / Best Sellers / New Arrivals|Medium  |Curated sections                               |
|Home: Search + category filter              |Medium  |                                               |
|Cancel order reason picker                  |Low     |Analytics for admin                            |
|Admin sales dashboard & charts              |Low     |                                               |
|Promo / discount codes                      |Low     |                                               |
|Language settings                           |Low     |                                               |
|Membership / VIP levels                     |Low     |                                               |

-----

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+ device or simulator
- A Firebase project with Firestore and Authentication enabled
- CocoaPods or Swift Package Manager (Firebase SDK)

### Setup

1. **Clone the repository**
   
   ```bash
   git clone https://github.com/your-username/CoffeeCraft.git
   cd CoffeeCraft
   ```
1. **Install dependencies**
   
   ```bash
   # If using Swift Package Manager, dependencies resolve automatically in Xcode
   # Firebase iOS SDK is required:
   # - FirebaseAuth
   # - FirebaseFirestore
   # - FirebaseMessaging
   ```
1. **Add your Firebase config**
- Download `GoogleService-Info.plist` from your Firebase Console
- Replace `CoffeeCraft/GoogleService-Info-Dev.plist` with your file
- Or add it as `GoogleService-Info.plist` and update `CoffeeCraftApp.swift` if needed
1. **Configure Firestore rules**
- Enable Email/Password in Firebase Auth
- Set Firestore rules to allow authenticated reads/writes for development
1. **Seed sample data (optional)**
- Uncomment the `Seed Database` button in `AccountView.swift` while in dev
- Run `ProductSeeder` and `BranchSeeder` to populate Firestore with sample products and branches
1. **Run the app**
- Select the `Dev` scheme in Xcode
- Choose a simulator or device
- Build & Run (`⌘R`)

### Test Accounts

Create test accounts via the Register screen:

- **Customer** — select role `Customer` at registration
- **Manager** — select role `Manager` to access the admin panel

-----

## Author

Built by **Sok Pich** · Started October 2025

-----

*CoffeeCraft — Portfolio project. Built with SwiftUI + Firebase.*