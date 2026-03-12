# 📊 Phase 8: Admin Dashboard — Implementation Plan

> **Status:** 🚧 In Progress  
> **Priority:** P0 (Critical)  
> **Estimated Timeline:** 2–3 weeks  
> **Target Version:** v1.1.0

---

## 🎯 Goals

Give managers a powerful, data-driven dashboard to monitor business health, manage users, moderate content, and make informed decisions — all from within the app.

---

## 📋 Feature Breakdown

### 8.1 — Dashboard Home (Overview Screen)
**The first screen managers see after logging in to the admin area.**

**KPI Summary Cards (top row):**
- Total Revenue Today / This Week / This Month (toggle)
- Total Orders Today (with % change vs. yesterday)
- Active Orders right now (live count)
- New Customers This Week

**Quick Glance Charts:**
- Mini revenue sparkline (last 7 days)
- Order volume bar chart (last 7 days)

**Live Activity Feed:**
- Real-time list of the last 10 orders (status + amount)
- Auto-updates via Firestore snapshot listener

**Data Source:**  
Aggregate from `orders` collection, group by `timestamp` date field.

---

### 8.2 — Sales Analytics
**Deep-dive into revenue and order trends.**

**Revenue Charts:**
- Line chart: Daily revenue for the selected period
- Bar chart: Weekly revenue comparison
- Period selector: Today / 7 Days / 30 Days / Custom range

**Order Analytics:**
- Total orders by status (Pending, Preparing, Ready, Completed, Cancelled)
- Peak ordering hours heatmap (hour × weekday grid)
- Average order value trend

**Payment Summary:**
- Total wallet top-ups vs. total spend
- Refund rate (cancelled orders / total orders × 100)

**Data Source:**  
Query `orders` collection filtered by `timestamp` range. Compute aggregations client-side (or via a Firestore aggregation query if count allows).

**New Firestore Field Needed:**
```
orders/{orderId}
  └── dateKey: "2026-03-12"   // YYYY-MM-DD string for easy daily grouping
```

---

### 8.3 — Product Performance
**Understand which products are driving revenue.**

**Best Sellers Table:**
- Ranked list of products by units sold (last 30 days)
- Columns: Rank, Product Name, Category, Units Sold, Revenue, Avg Rating

**Product Revenue Breakdown:**
- Pie / donut chart of revenue share by category
- Top 5 products bar chart

**Rating vs. Sales Scatter (bonus):**
- X-axis: Avg rating, Y-axis: Units sold
- Quick view of high-rated but low-selling items (marketing opportunity)

**Data Source:**  
Iterate `orders` collection, explode `items` array, group by `productId`.  
Cross-reference with `products` collection for name/category/rating.

**New Firestore Collection (optional, for performance):**
```
productStats/{productId}
  ├── totalSold: Int
  ├── totalRevenue: Double
  └── lastUpdated: Timestamp
```
Update this via a Cloud Function on order status change to `Completed` — or compute on-the-fly with pagination.

---

### 8.4 — Order Analytics Dashboard
**Operational view for order management efficiency.**

**Order Queue (real-time):**
- Live list of all active orders (Pending + Preparing)
- Sorted by timestamp ascending (oldest first)
- Color-coded by status
- One-tap status update inline (Pending → Preparing → Ready)

**Historical Order Table:**
- Filterable by: Status, Date Range, Branch
- Sortable by: Date, Amount
- Search by Order ID or Customer Name

**Order Funnel:**
- Completion rate: Completed / (Total - Pending)
- Cancellation rate: Cancelled / Total
- Average time from Pending → Completed (if `completedAt` timestamp added)

**New Firestore Field Needed:**
```
orders/{orderId}
  └── completedAt: Timestamp   // Set when status changes to Completed
```

---

### 8.5 — User Management Panel
**View and manage the customer base.**

**User List:**
- Paginated list of all users (role: customer)
- Columns: Name, Email, Join Date, Total Orders, Total Spent, Loyalty Points
- Search by name or email

**User Detail View:**
- Full profile info
- Order history (last 10)
- Wallet balance (read-only)
- Loyalty card(s)
- Action: Send notification to this user

**Data Source:**  
Query `users` collection where `role == "customer"`.  
Join with `orders` collection (group by `userId`) for order count and spend.

> ⚠️ **Note:** Wallet balance is read from `wallets/{userId}` — managers have read-only access.

---

### 8.6 — Review Moderation Dashboard
**Upgrade the existing basic moderation into a structured workflow.**

**Review Queue:**
- List of all non-hidden reviews, newest first
- Shows: Product name, Customer name, Rating (stars), Review excerpt, Date
- Quick actions: Hide / Unhide inline

**Filters:**
- By product
- By rating (1★ only, etc.)
- By status: All / Visible / Hidden

**Review Analytics Per Product:**
- Average rating over time (line chart)
- Rating distribution (existing bar chart, surfaced here)
- Total reviews count vs. hidden count

**Data Source:**  
`products/{productId}/reviews/{reviewId}` — already exists.

---

## 🗂️ Module Structure

```
Module/
└── AdminDashboard/
    ├── Model/
    │   ├── DashboardSummary.swift        # KPI data model
    │   ├── SalesDataPoint.swift          # Chart data point
    │   ├── ProductStat.swift             # Product performance model
    │   └── UserStat.swift                # Enriched user model
    │
    ├── Service/
    │   └── AnalyticsService.swift        # All Firestore aggregation queries
    │
    ├── ViewModel/
    │   ├── DashboardHomeViewModel.swift
    │   ├── SalesAnalyticsViewModel.swift
    │   ├── ProductPerformanceViewModel.swift
    │   ├── OrderAnalyticsViewModel.swift
    │   ├── UserManagementViewModel.swift
    │   └── ReviewModerationViewModel.swift
    │
    └── View/
        ├── AdminDashboardHomeView.swift      # 8.1
        ├── SalesAnalyticsView.swift          # 8.2
        ├── ProductPerformanceView.swift      # 8.3
        ├── OrderAnalyticsDashboardView.swift # 8.4
        ├── UserManagementView.swift          # 8.5
        ├── UserDetailView.swift
        ├── ReviewModerationDashboardView.swift # 8.6
        └── Components/
            ├── KPICard.swift
            ├── MiniSparklineChart.swift
            ├── StatBarChart.swift
            ├── OrderStatusBadge.swift
            └── LiveActivityRow.swift
```

---

## 🗄️ Firestore Changes

| Change | Field | Collection | Reason |
|--------|-------|-----------|--------|
| Add | `dateKey: String` | `orders` | Fast daily grouping without date math |
| Add | `completedAt: Timestamp` | `orders` | Calculate fulfillment time |
| New (optional) | `productStats/{productId}` | root | Cache aggregated product stats |

Set `dateKey` and `completedAt` in the existing `OrderService` when updating order status.

---

## 📊 Charts Library Decision

SwiftUI's native **Swift Charts** (iOS 16+) — already available, zero dependencies.

| Chart Type | Swift Charts Component | Used In |
|-----------|----------------------|---------|
| Line chart | `LineMark` | Revenue trend, Rating over time |
| Bar chart | `BarMark` | Order volume, Category breakdown |
| Pie/Donut | `SectorMark` | Revenue by category |
| Point chart | `PointMark` | Rating vs. Sales scatter |
| Area chart | `AreaMark` | Revenue sparkline |

---

## 🔐 Access Control

All admin dashboard screens must be gated:

```swift
// In view entry point
guard UserSession.shared.currentUser?.role == "manager" else {
    return // redirect or show error
}
```

Firestore security rules should also enforce manager-only reads on aggregation paths.

---

## 🏗️ Implementation Order

Build in this sequence to deliver value incrementally:

```
Week 1
  Day 1–2:  8.1 Dashboard Home (KPI cards + live feed)
  Day 3–4:  8.4 Order Analytics Dashboard (real-time queue upgrade)
  Day 5:    Firestore schema updates (dateKey, completedAt)

Week 2
  Day 1–2:  8.2 Sales Analytics (charts)
  Day 3:    8.3 Product Performance
  Day 4–5:  8.6 Review Moderation Dashboard (upgrade existing)

Week 3
  Day 1–3:  8.5 User Management Panel
  Day 4:    Polish, loading states, empty states
  Day 5:    Testing + README update
```

---

## ✅ Acceptance Criteria

| Feature | Criteria |
|---------|---------|
| Dashboard Home | KPI cards load within 2s; live feed updates without manual refresh |
| Sales Analytics | Charts render for Today / 7D / 30D; period toggle works smoothly |
| Product Performance | Best sellers list is accurate vs. raw order data |
| Order Analytics | Real-time queue reflects order status changes within 1s |
| User Management | Pagination works; user detail shows accurate order history |
| Review Moderation | Hide/unhide updates immediately; filters work correctly |
| Access Control | Non-manager users cannot access any admin screen |

---

## 🚫 Out of Scope (Phase 8)

These are deferred to later phases:
- Push notification broadcasts to all users (Phase 9+)
- Export to CSV / PDF reports
- Branch-level analytics comparison
- Custom date range picker (use presets only for now)
- Cloud Functions for server-side aggregation

---

## 📝 Notes

- All analytics are **client-side computed** from Firestore queries. If data volume grows large (10k+ orders), migrate heavy aggregations to Cloud Functions.
- Use `async/await` with `withTaskGroup` for parallel Firestore fetches on the Dashboard Home to keep load time under 2 seconds.
- Reuse existing `CustomRefreshScrollView`, `ShimmerView`, and `ToastManager` from the Custom component libraryd.
- Charts should respect the app's dark mode theme — use `Color.primary` / semantic colors, not hardcoded hex values.
