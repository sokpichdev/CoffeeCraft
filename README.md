# ☕ CoffeeCraft

> A production-grade iOS coffee shop application built with **SwiftUI** and **Firebase** — featuring dual user roles, real-time order tracking, wallet payments, reviews & ratings, loyalty cards, and comprehensive admin tools.

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg" alt="Platform: iOS 17+"/>
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange.svg" alt="Swift 5.9+"/>
  <img src="https://img.shields.io/badge/Framework-SwiftUI-green.svg" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Backend-Firebase-yellow.svg" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success.svg" alt="Production Ready"/>
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Module Breakdown](#-module-breakdown)
- [Firestore Schema](#-firestore-schema)
- [Custom Components](#-custom-components)
- [Getting Started](#-getting-started)
- [Environment Configuration](#-environment-configuration)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**CoffeeCraft** is a full-featured iOS application that simulates a real-world coffee shop experience with two distinct user roles — **Customer** and **Manager**. The app demonstrates production-grade iOS development patterns and best practices.

### What Makes CoffeeCraft Special?

- **🎭 Dual User Roles:** Complete customer and manager experiences in one app
- **⚡ Real-time Everything:** Live order updates, wallet sync, push notifications
- **💳 Full Payment System:** In-app wallet with top-up, transactions, and refunds
- **⭐ Reviews & Ratings:** Proof-of-purchase verified reviews with helpful voting
- **🎴 Loyalty System:** Multi-card support with sharing capabilities
- **🗺️ Store Locator:** MapKit integration with branch details
- **🎨 Custom UI Library:** 30+ reusable SwiftUI components
- **🏗️ Production Architecture:** MVVM, real-time listeners, transaction-based operations

### Built For Learning & Portfolio

This project showcases:
- Advanced SwiftUI techniques
- Firebase integration (Auth, Firestore, FCM)
- Real-time data synchronization
- Transaction-based database operations
- Custom navigation system
- Reusable component library
- Dark mode theming
- Role-based access control

---

## ✨ Key Features

### 👤 Customer Features

#### 🛒 Shopping & Orders
- ✅ Browse product catalog with categories
- ✅ Search products by name
- ✅ Filter by category (Coffee, Tea, Espresso, Latte, etc.)
- ✅ Detailed product view with customization options
- ✅ Add to cart with size, temperature, extras
- ✅ Shopping cart management
- ✅ Wallet-based checkout
- ✅ Real-time order tracking
- ✅ Order status timeline (Pending → Preparing → Ready → Completed)
- ✅ Cancel orders (Pending status only) with auto-refund
- ✅ Reorder with one tap
- ✅ Order receipt view

#### ⭐ Reviews & Ratings
- ✅ Rate products 1-5 stars (verified purchases only)
- ✅ Write reviews with title and body
- ✅ Edit/delete your reviews
- ✅ Mark reviews as helpful
- ✅ View rating distribution
- ✅ Sort by: Most Recent, Most Helpful
- ✅ Proof of purchase validation

#### 💰 Wallet & Payments
- ✅ In-app wallet with balance tracking
- ✅ Multi-step top-up flow (Amount → Bank → Checkout)
- ✅ Transaction history (Top-up, Payment, Refund)
- ✅ Filter transactions by type
- ✅ Real-time balance updates
- ✅ Atomic payment transactions

#### 🎴 Loyalty & Rewards
- ✅ Loyalty points system
- ✅ Multiple loyalty cards support
- ✅ Share cards with other users
- ✅ Flippable card UI (3D animation)
- ✅ Points accumulation on orders
- ✅ Active card selection

#### 📍 Discover & Explore
- ✅ Store locator with MapKit
- ✅ Branch details (hours, amenities, contact)
- ✅ Get directions to store
- ✅ Distance calculation from your location
- ✅ Favorites/wishlist
- ✅ Announcements feed
- ✅ Infinite banner carousel

#### 👨‍💼 Profile & Settings
- ✅ View and edit profile
- ✅ Change password
- ✅ Notification inbox
- ✅ Dark mode toggle
- ✅ Theme customization
- ✅ Order history
- ✅ Account settings

### 👨‍💼 Manager Features

#### 📦 Product Management
- ✅ Create new products
- ✅ Edit existing products
- ✅ Delete products
- ✅ Set product availability
- ✅ Manage customization options
- ✅ Upload product images
- ✅ Categorize products
- ✅ Seed sample data

#### 📋 Order Management
- ✅ Real-time order dashboard
- ✅ Update order status
- ✅ Order queue view
- ✅ Send push notifications to customers
- ✅ View customer details
- ✅ Order analytics (in progress)

#### 🛡️ Review Moderation
- ✅ View all product reviews
- ✅ Hide inappropriate reviews
- ✅ Review analytics per product

#### 📊 Analytics (Partial)
- ⚠️ Dashboard views (in development)
- ⚠️ Sales reporting (planned)
- ⚠️ Best-selling products (planned)

---

## 📱 Screenshots

> *Screenshots coming soon*

---

## 🏗️ Architecture

CoffeeCraft follows a **clean MVVM architecture** with additional layers for scalability:

```
┌─────────────────────────────────────────┐
│            SwiftUI Views                │
│  (Stateless, declarative UI components) │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│          ViewModels (@MainActor)        │
│   (Business logic, state management)    │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│        Service Layer (Singletons)       │
│  WalletService, RatingService, etc.     │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│            Firebase Backend             │
│  (Firestore, Auth, Cloud Messaging)     │
└─────────────────────────────────────────┘
```

### Architecture Highlights

- **MVVM Pattern:** Clear separation of concerns
- **@MainActor:** Thread-safe UI updates
- **Singleton Services:** Centralized business logic
- **Real-time Listeners:** Firestore snapshot listeners
- **Transaction-Based:** Atomic operations for critical flows
- **Custom Navigation:** Type-safe navigation with environment injection
- **Dependency Injection:** @EnvironmentObject for shared state

### Key Design Patterns

| Pattern | Usage |
|---------|-------|
| **MVVM** | Core architectural pattern |
| **Singleton** | Services (UserSession, WalletService, RatingService) |
| **Observer** | Real-time Firestore listeners |
| **Factory** | Model creation (Review.create(), Product.empty()) |
| **Strategy** | Payment methods, transaction types |
| **Repository** | Firebase data access abstraction |
| **Coordinator** | Custom navigation system |

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | SwiftUI | Declarative UI |
| **Backend** | Firebase | Authentication, Database, Messaging |
| **Database** | Cloud Firestore | NoSQL real-time database |
| **Authentication** | Firebase Auth | Email/Password auth |
| **Push Notifications** | Firebase Cloud Messaging | Order updates |
| **Maps** | MapKit + CoreLocation | Store locator |
| **Image Loading** | AsyncImage | Async image fetching |
| **State Management** | @StateObject, @EnvironmentObject | Reactive state |
| **Persistence** | @AppStorage | UserDefaults wrapper |
| **Architecture** | MVVM | Design pattern |
| **Minimum iOS** | iOS 17+ | Latest SwiftUI features |
| **Language** | Swift 5.9+ | Type-safe programming |

---

## 📁 Project Structure

```
CoffeeCraft/
├── Main/
│   ├── View/
│   │   ├── CoffeeCraftApp.swift          # App entry point
│   │   ├── RootView.swift                # Auth gate
│   │   ├── ContentView.swift             # Main container
│   │   ├── TabBarView.swift              # Custom tab bar
│   │   └── AppDelegate.swift             # FCM setup
│   └── ViewModel/
│       └── MainViewModel.swift
│
├── Module/                               # Feature modules (15 total)
│   ├── Auth/                             # Authentication
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   ├── Home/                             # Landing screen
│   │   ├── Announcement/
│   │   └── View/
│   │
│   ├── Menu/                             # Product catalog
│   │   ├── Product/
│   │   ├── Category/
│   │   ├── Search/
│   │   └── View/
│   │
│   ├── ProductCustomization/             # Drink customization
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   ├── Cart/                             # Shopping cart
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   ├── Order/                            # Order management
│   │   ├── OrderListing/
│   │   ├── OrderDetail/
│   │   └── OrderReceipt/
│   │
│   ├── Wallet/                           # Payment system
│   │   ├── MVVM/
│   │   ├── TopUp/
│   │   └── Firebase/
│   │
│   ├── Review/                           # ⭐ NEW: Ratings & Reviews
│   │   ├── Model/
│   │   ├── View/
│   │   ├── ViewModel/
│   │   └── Services/
│   │
│   ├── Favorites/                        # Wishlist
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   ├── Map/                              # Store locator
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   ├── Account/                          # User profile
│   │   ├── Inbox/
│   │   ├── Puchase-Cards/               # ⭐ NEW: Loyalty cards
│   │   └── View/
│   │
│   ├── Profile/                          # Edit profile
│   │   ├── Model/
│   │   └── View/
│   │
│   ├── Notification/                     # Push notifications
│   ├── Theme/                            # Dark mode
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   │
│   └── Settings/                         # App settings
│       └── View/
│
├── Custom/                               # 30+ Reusable components
│   ├── Navigation/
│   │   ├── PushLink.swift
│   │   └── CustomNavigationBar.swift
│   │
│   ├── API_UI_Components/
│   │   ├── AlertManager.swift
│   │   └── ToastManager.swift
│   │
│   ├── Scroll/
│   │   └── CustomRefreshScrollView.swift
│   │
│   ├── MaterialTextField.swift
│   ├── InfiniteCarousel.swift
│   ├── ChipFlowLayout.swift
│   ├── AsyncImageCard.swift
│   ├── ShimmerView.swift
│   └── ... (30+ components)
│
├── Extension/
│   ├── Color+Ex.swift                   # Semantic colors
│   ├── View+Ex.swift                    # View helpers
│   ├── String+Ex.swift                  # String utilities
│   └── Fonts/                           # Custom fonts
│
├── Constants/
│   └── Constants.swift                  # App constants
│
├── Utilize/
│   ├── UserSession.swift                # Session manager
│   ├── AppLog.swift                     # Structured logging
│   └── Network/                         # Network monitor
│
├── Preference/                          # User preferences
│
├── Resource/                            # Assets, fonts, images
│
└── docs/
    ├── FeaturePlanning.md
    └── firestore-schema.md
```

**Statistics:**
- **211 Swift files**
- **15 core modules**
- **30+ custom UI components**
- **~15,000+ lines of code**

---

## 📦 Module Breakdown

### Core Modules

| Module | Status | Files | Description |
|--------|--------|-------|-------------|
| **Auth** | ✅ Complete | 7 | Email/Password authentication, registration, password reset |
| **Home** | ✅ Complete | 6+ | Landing screen, banners, announcements, quick actions |
| **Menu** | ✅ Complete | 14+ | Product catalog, search, categories, product management |
| **ProductCustomization** | ✅ Complete | 4 | Dynamic customization UI for drinks |
| **Cart** | ✅ Complete | 5 | Shopping cart, checkout flow |
| **Order** | ✅ Complete | 15+ | Order tracking, status updates, receipts, cancellation |
| **Wallet** | ✅ Complete | 10+ | Balance, top-up, transactions, payments |
| **Review** | ✅ Complete | 8 | Ratings, reviews, proof of purchase, moderation |
| **Favorites** | ✅ Complete | 4 | Wishlist functionality |
| **Map** | ✅ Complete | 5 | Store locator, branch details, directions |
| **Account** | ✅ Complete | 15+ | Profile, inbox, loyalty cards |
| **Notification** | ✅ Complete | 3 | FCM integration, push notifications |
| **Theme** | ✅ Complete | 4 | Dark mode, color system |
| **Settings** | ✅ Complete | 2 | App settings, preferences |
| **Profile** | ✅ Complete | 4 | Edit profile, change password |

---

## 🗄️ Firestore Schema

### Collections Overview

```
firestore
├── users/{userId}
│   ├── fcmTokens/{deviceId}
│   └── favorites/{productId}
│
├── products/{productId}
│   ├── ratings/{userId}
│   └── reviews/{reviewId}
│
├── carts/{userId}
├── orders/{orderId}
├── wallets/{userId}
├── branches/{branchId}
├── announcements/{announcementId}
└── loyaltyCards/{cardId}
```

### Key Document Schemas

#### User Document
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "role": "customer",
  "points": 150,
  "createdAt": "<Timestamp>"
}
```

#### Product Document
```json
{
  "name": "Cappuccino",
  "description": "Classic Italian coffee...",
  "price": 4.50,
  "imageURL": "https://...",
  "category": "Coffee",
  "available": true,
  "customizations": {
    "Size": {"Small": 0.0, "Large": 1.0},
    "Temperature": {"Hot": 0.0, "Iced": 0.5}
  },
  "avgRating": 4.3,
  "ratingCount": 127,
  "ratingDistribution": {"5": 80, "4": 30, "3": 10, "2": 5, "1": 2}
}
```

#### Order Document
```json
{
  "userId": "<uid>",
  "items": [...],
  "totalPrice": 12.50,
  "status": "Preparing",
  "timestamp": "<Timestamp>",
  "productIds": ["prod1", "prod2"],
  "branchId": "branch1"
}
```

#### Rating Document
```json
{
  "score": 5,
  "orderId": "order123",
  "reviewId": "review456",
  "createdAt": "<Timestamp>",
  "updatedAt": "<Timestamp>"
}
```

#### Review Document
```json
{
  "userId": "<uid>",
  "userName": "Jane Doe",
  "orderId": "order123",
  "rating": 5,
  "title": "Absolutely perfect!",
  "body": "Best cappuccino I've ever had...",
  "helpfulCount": 12,
  "helpfulBy": ["user1", "user2"],
  "isHidden": false,
  "createdAt": "<Timestamp>"
}
```

#### Loyalty Card Document
```json
{
  "cardNumber": "CC-2026-0001",
  "ownerId": "<uid>",
  "ownerName": "Jane Doe",
  "memberSince": "2026-01-15",
  "points": 250,
  "sharedWith": ["user2", "user3"],
  "createdAt": "<Date>"
}
```

---

## 🎨 Custom Components

CoffeeCraft includes **30+ reusable SwiftUI components**:

### Form & Input
- `MaterialTextField` - Floating label with validation
- `CustomTextField1` - Extended field with icons
- `CustomSecureField` - Password input
- `CustomNumberField` - Numeric input

### Selection
- `CustomSegmentedControl` - Styled segment picker
- `CustomSingleSelectionView` - Radio button grid
- `CustomMultipleSelectionView` - Checkbox grid
- `ChipFlowLayout` - Wrapping chip layout
- `PickerSheetView` - Bottom sheet picker

### Media & Display
- `AsyncImageCard` - Image with shimmer loading
- `InfiniteCarousel` - Auto-scrolling carousel
- `WebView` - WKWebView wrapper
- `ShimmerView` - Skeleton loading effect

### Navigation
- `PushLink` - Custom navigation link
- `CustomNavigationBar` - Bespoke nav bar
- `ToolBarButton` - Toolbar button

### Feedback
- `AlertManager` - Global alert system
- `ToastManager` - Toast notifications
- `ComingSoonView` - Feature placeholder

### Layout
- `ActionCardButton` - Large card button
- `CustomRefreshScrollView` - Pull-to-refresh
- `MinimumLoadingTime` - Loading duration enforcer

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15+**
- **iOS 17+** device or simulator
- **Firebase project** with:
  - Authentication enabled (Email/Password)
  - Cloud Firestore database
  - Cloud Messaging enabled
- **CocoaPods** or **Swift Package Manager**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/CoffeeCraft.git
   cd CoffeeCraft
   ```

2. **Install dependencies**
   
   Dependencies are managed via Swift Package Manager and should resolve automatically when opening the project in Xcode.
   
   Required Firebase packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseMessaging

3. **Firebase setup**
   
   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   
   b. Enable Email/Password authentication:
      - Go to Authentication → Sign-in method
      - Enable Email/Password provider
   
   c. Create a Firestore database:
      - Go to Firestore Database
      - Create database in production mode
      - Set initial rules (see below)
   
   d. Enable Cloud Messaging:
      - Go to Cloud Messaging
      - Add iOS app with your bundle ID
   
   e. Download `GoogleService-Info.plist`:
      - Replace `CoffeeCraft/GoogleService-Info-Dev.plist` with your file

4. **Firestore Security Rules** (Development)
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
   
   ⚠️ **Important:** Update rules for production deployment!

5. **Seed sample data** (Optional)
   
   - Run the app
   - Go to Account tab
   - Tap "Seed Database" (only visible in Dev environment)
   - This will populate:
     - Sample products
     - Store branches
     - Announcements

6. **Build and run**
   ```
   - Open CoffeeCraft.xcodeproj in Xcode
   - Select Dev scheme
   - Choose target device/simulator
   - Press ⌘R to build and run
   ```

### Creating Test Accounts

Use the Register screen to create accounts:

**Customer Account:**
- Name: Test Customer
- Email: customer@test.com
- Password: Test123!
- Role: Customer

**Manager Account:**
- Name: Test Manager
- Email: manager@test.com
- Password: Test123!
- Role: Manager

---

## ⚙️ Environment Configuration

CoffeeCraft supports multiple Firebase environments:

```swift
enum FirebaseEnvironment {
    case dev    // Development
    case sit    // System Integration Testing
    case uat    // User Acceptance Testing
    case prod   // Production
}
```

### Setting Up Environments

1. Duplicate the `Dev` scheme in Xcode
2. Rename to `SIT`, `UAT`, or `Prod`
3. Add corresponding `GoogleService-Info.plist` files:
   - `GoogleService-Info-Dev.plist`
   - `GoogleService-Info-SIT.plist`
   - `GoogleService-Info-UAT.plist`
   - `GoogleService-Info.plist` (production)

4. Update `CoffeeCraftApp.swift` to select the correct config based on build scheme

---

## 🗺️ Roadmap

### ✅ Phase 1-7: Completed (v1.0)

| Phase | Features | Status |
|-------|----------|--------|
| **Phase 1** | Auth, Basic Product CRUD | ✅ |
| **Phase 2** | Cart, Checkout, Orders | ✅ |
| **Phase 3** | Wallet System, Payments | ✅ |
| **Phase 4** | Real-time Order Tracking | ✅ |
| **Phase 5** | Push Notifications, Inbox | ✅ |
| **Phase 6** | Favorites, Maps, Profile | ✅ |
| **Phase 7** | Reviews, Ratings, Loyalty Cards | ✅ |

### 🚧 Phase 8: Admin Dashboard (In Progress)

- [ ] Sales analytics dashboard
- [ ] Product performance metrics
- [ ] Revenue charts (daily/weekly/monthly)
- [ ] User management panel
- [ ] Review moderation dashboard
- [ ] Order analytics

**Priority:** P0 (Critical)  
**Timeline:** 2-3 weeks

### 📅 Phase 9: Customer Experience (Planned)

- [ ] Home screen curated sections
  - [ ] Featured products
  - [ ] Best sellers (dynamic)
  - [ ] New arrivals
- [ ] Product availability badges
- [ ] Recently viewed products
- [ ] Advanced search & filters
- [ ] Order tracking enhancements

**Priority:** P1 (High)  
**Timeline:** 2 weeks

### 💰 Phase 10: Monetization (Planned)

- [ ] Promo code system
- [ ] Membership tiers (Bronze, Silver, Gold)
- [ ] Gift cards & vouchers
- [ ] Birthday rewards
- [ ] Referral program

**Priority:** P1 (High)  
**Timeline:** 2-3 weeks

### 🔮 Phase 11: Advanced Features (Future)

- [ ] Multiple payment methods (Stripe integration)
- [ ] Saved addresses
- [ ] Delivery mode
- [ ] Order scheduling
- [ ] Language localization (Khmer)
- [ ] Social sharing
- [ ] Group orders

**Priority:** P2-P3 (Medium-Low)  
**Timeline:** TBD

### 🛠️ Technical Improvements (Ongoing)

- [ ] Firebase Analytics integration
- [ ] Crashlytics setup
- [ ] Unit test coverage (target 60%)
- [ ] UI automation tests
- [ ] Offline mode support
- [ ] Image caching optimization
- [ ] Performance monitoring

---

## 📊 Project Statistics

- **Total Swift Files:** 211
- **Core Modules:** 15
- **Custom Components:** 30+
- **Firestore Collections:** 9
- **Lines of Code:** ~15,000+
- **Development Time:** 6+ months
- **Status:** Production-ready

---

## 🤝 Contributing

This is a portfolio/learning project, but contributions are welcome!

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow Swift style guide
- Use MVVM pattern
- Add comments for complex logic
- Include unit tests for new features
- Update documentation

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Sok Pich**  
iOS Developer | SwiftUI Enthusiast

- GitHub: [@cobra-PICH](https://github.com/cobra-PICH)
- Portfolio: [your-portfolio.com](https://your-portfolio.com)

---

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- SwiftUI community for inspiration
- Coffee shops everywhere for the inspiration ☕

---

## 📞 Support

For questions or issues:
- Open an issue on GitHub
- Email: pichsok016@gmail.com

---

<p align="center">
  <strong>Built with ☕ and Swift</strong><br>
  CoffeeCraft © 2026
</p>

---

## 🔗 Related Documentation

- [PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md) - Comprehensive technical documentation
- [FEATURE_PRIORITY_PLAN.md](docs/FEATURE_PRIORITY_PLAN.md) - Strategic feature roadmap
- [firestore-schema.md](CoffeeCraft/docs/firestore-schema.md) - Database schema reference
- [FeaturePlanning.md](CoffeeCraft/docs/FeaturePlanning.md) - Feature checklist

---

## 📸 App Preview

> *Coming soon: Screenshots and demo video*

**Key Screens:**
- Authentication (Login/Register)
- Home Dashboard
- Product Menu & Search
- Product Detail & Customization
- Shopping Cart
- Order Tracking
- Reviews & Ratings
- Wallet & Top-up
- Loyalty Cards
- Store Map
- Profile & Settings
- Admin Dashboard

---

**Status:** ✅ Production Ready | **Version:** 1.0 | **Last Updated:** March 2026
