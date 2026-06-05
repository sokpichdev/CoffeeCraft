<h1 align="center">CoffeeCraft ☕</h1>

<p align="center">
  A full-featured coffee shop ordering app built with <strong>SwiftUI + Firebase</strong>.<br/>
  Dual-role experience for <strong>Customers</strong> and <strong>Managers</strong> — real-time orders, in-app wallet, loyalty cards, and an admin dashboard.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-000000?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/SwiftUI-0A84FF?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Xcode-15%2B-147EFB?style=for-the-badge&logo=xcode&logoColor=white"/>
</p>

<p align="center">
  <a href="mailto:pichsok016@gmail.com"><img src="https://img.shields.io/badge/Contact-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a>
  <a href="https://portfolio-flame-eta-etrjgpxb96.vercel.app/"><img src="https://img.shields.io/badge/Portfolio-000000?style=for-the-badge&logo=vercel&logoColor=white"/></a>
</p>

---

## 📸 Screenshots

### 👤 Customer

<p align="center">
  <img src="screenshots/customers/loading.png" width="160"/>
  <img src="screenshots/customers/login.png" width="160"/>
  <img src="screenshots/customers/signup.png" width="160"/>
  <img src="screenshots/customers/forget_password.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/home.gif" width="160"/>
  <img src="screenshots/customers/menu.png" width="160"/>
  <img src="screenshots/customers/search_menu.png" width="160"/>
  <img src="screenshots/customers/product_detail.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/cart.png" width="160"/>
  <img src="screenshots/customers/store_selection.png" width="160"/>
  <img src="screenshots/customers/pickup_delivery.png" width="160"/>
  <img src="screenshots/customers/delivery.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/payment_method.png" width="160"/>
  <img src="screenshots/customers/orders.png" width="160"/>
  <img src="screenshots/customers/order_detail.png" width="160"/>
  <img src="screenshots/customers/ratings_reviews.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/wallet.png" width="160"/>
  <img src="screenshots/customers/topup.png" width="160"/>
  <img src="screenshots/customers/find_branch.png" width="160"/>
  <img src="screenshots/customers/branch_info.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/account.png" width="160"/>
  <img src="screenshots/customers/edit_profile.png" width="160"/>
  <img src="screenshots/customers/shared_cards.png" width="160"/>
  <img src="screenshots/customers/settings.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/customers/color_pallete.png" width="160"/>
</p>

### 🛠 Admin / Manager

<p align="center">
  <img src="screenshots/admin/inbox.png" width="160"/>
  <img src="screenshots/admin/order_analytics_history.png" width="160"/>
  <img src="screenshots/admin/order_analytics_funnel.png" width="160"/>
  <img src="screenshots/admin/pick_ordering_hours.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/admin/sales_analytics.png" width="160"/>
  <img src="screenshots/admin/rating_sales.png" width="160"/>
  <img src="screenshots/admin/product_performance.png" width="160"/>
  <img src="screenshots/admin/best_sellers.png" width="160"/>
</p>
<p align="center">
  <img src="screenshots/admin/review_moderation.png" width="160"/>
  <img src="screenshots/admin/users_info.png" width="160"/>
  <img src="screenshots/admin/users_detail.png" width="160"/>
</p>

---

## ✨ Features

### 👤 Customer
- Browse menu with category filters and real-time availability
- Customize drinks (size, extras, options) with dynamic pricing
- In-app wallet — top-up, pay, and get refunds atomically
- Real-time order tracking: `Pending → Preparing → Ready → Completed`
- Cancel pending orders with instant wallet refund
- Proof-of-purchase verified reviews with star ratings
- Loyalty card management and point rewards
- Push notification deep-links to the Orders tab
- Store locator with MapKit and branch detail (hours, amenities, directions)

### 🛠 Manager
- Full order queue with status control and FCM push to customers
- Product CRUD — add, edit, delete, toggle availability
- Admin dashboard: revenue KPIs, order analytics, product performance, sales heatmap
- Review moderation — hide/unhide per product

---

## 🏗 Architecture

**Pattern:** MVVM + Repository, with `@EnvironmentObject` dependency injection.

```
View (SwiftUI)
  └─ ViewModel (@MainActor, @Published state)
       └─ Repository Protocol
            └─ Firebase Repository (Firestore / Firebase Auth)
```

<p>
  <img src="https://img.shields.io/badge/MVVM-6C63FF?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Repository_Pattern-FF9800?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Clean_Architecture-4CAF50?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Protocol--Oriented-9C27B0?style=for-the-badge"/>
</p>

ViewModels never import Firebase directly — they depend only on repository protocols, making them fully testable in isolation.

### Real-Time Data Strategy

| Strategy | Used For |
|---|---|
| Snapshot listeners | Products, wallet balance, transactions, inbox |
| Cursor-based pagination | Orders (pageSize = 5, listener covers all loaded pages) |
| `db.runTransaction()` | Wallet top-up, order payment, refund — atomic across multiple docs |

---

## 🛠 Tech Stack

<p>
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/SwiftUI-0A84FF?style=for-the-badge&logo=swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase_Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/MapKit-000000?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Crashlytics-FF3B30?style=for-the-badge&logo=firebase&logoColor=white"/>
  <img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white"/>
</p>

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15+, iOS 17 simulator or device
- A Firebase project with Auth, Firestore, and Cloud Messaging enabled

### Setup

```bash
git clone https://github.com/sokpichdev/CoffeeCraft.git
cd CoffeeCraft
open CoffeeCraft/CoffeeCraft.xcodeproj
```

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an iOS app with bundle ID `com.sokpich.CoffeeCraft.dev`
3. Enable **Email/Password** auth and create a **Firestore** database
4. Download `GoogleService-Info.plist`, rename it `GoogleService-Info-Dev.plist`, and place it in `CoffeeCraft/CoffeeCraft/`
5. Select the `CoffeeCraft-Dev` scheme and press `Cmd+R`

> `GoogleService-Info*.plist` is gitignored — never commit it.

### Firestore Rules (dev)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📦 Project Structure

```
CoffeeCraft/
├── Main/               # App entry, RootView, TabBarView, AppDelegate
├── Module/             # Feature modules (Auth, Home, Menu, Cart, Order, Wallet, ...)
├── Repository/         # Protocol + Firebase implementations per domain
├── Custom/             # 30+ reusable SwiftUI components
├── Extension/          # Color tokens, Font system, View helpers
├── Utilize/            # UserSession, AppLog, NetworkMonitor, Analytics
├── Constants/          # FirebaseKeys — all Firestore collection/field constants
└── docs/               # Firestore schema, architecture, theme, navigation docs
```

### Schemes

| Scheme | Purpose |
|---|---|
| `CoffeeCraft-Dev` | Local development |
| `CoffeeCraft-SIT` | System integration testing |
| `CoffeeCraft-UAT` | User acceptance testing |
| `CoffeeCraft` | Production |

---

## 🎨 Theme System

Four color palettes — **Brown**, **Strawberry**, **Matcha**, **Oreo** — with light/dark mode support. All colors are semantic tokens (`Color.accentPrimary`, `Color.bgPrimary`, etc.) that automatically adapt to the active palette and appearance. Persisted via `@AppStorage`.

---

## 🔒 Security Notes

- `GoogleService-Info*.plist` is gitignored — add your own for each environment
- All wallet mutations use Firestore transactions (atomic, no partial writes)
- Never commit `.env` or any credential files — they are blocked by `.gitignore`

---

<p align="center">
  ☕ <i>"First, solve the problem. Then, write the code. Then, drink more coffee."</i><br/><br/>
  <strong>Author:</strong> Sok Pich — iOS Developer &nbsp;|&nbsp; <a href="mailto:pichsok016@gmail.com">pichsok016@gmail.com</a>
</p>
