# CoffeeCraft — Custom UI Component Catalog

All reusable components live under `CoffeeCraft/Custom/`. Before building any new UI primitive, check this catalog. Using existing components keeps the app visually consistent and theme-responsive.

---

## Input Components

### MaterialTextField

File: `Custom/MaterialTextField.swift`

A floating-label text field. The label starts at the placeholder position and animates up when the field has focus or a value. Supports validation state display (error message below the field).

Use this for all primary text inputs in forms (email, name, city, etc.).

```swift
MaterialTextField(
    label: "Email Address",
    text: $email,
    errorMessage: emailError
)
```

### CustomTextField1

File: `Custom/CustomTextField1.swift`

Extended text field that supports a leading icon. Use when the field's purpose benefits from a visual icon (e.g., a search icon for search inputs).

### CustomSecureField

File: `Custom/CustomSecureField.swift`

Password input with a show/hide toggle button. Use this instead of a plain `SecureField` for all password inputs.

### CustomNumberField

File: `Custom/CustomNumberField.swift`

Numeric-only input with a `keyboardType` of `.decimalPad`. Use for price inputs and quantity fields.

### CustomProductTextField

File: `Custom/CustomProductTextField.swift`

Specialized text field for product form inputs in the manager product edit screen.

---

## Selection Components

### CustomSegmentedControl

File: `Custom/CustomSegmentedControl.swift`

A styled segment picker that matches the app's accent color. Use instead of the system `Picker(.segmented)` to stay on-brand.

```swift
CustomSegmentedControl(
    selectedIndex: $selectedIndex,
    titles: ["Hot", "Iced", "Blended"]
)
```

### CustomSingleSelectionView

File: `Custom/CustomSingleSelectionview.swift`

A grid of tappable options where only one can be selected at a time (radio button style). Used in the product customization sheet for options like Size and Temperature.

### CustomMultipleSelectionView

File: `Custom/CustomMultipleSelectionView.swift`

A grid of tappable options where multiple can be selected simultaneously (checkbox style). Used in the product customization sheet for the Extras group.

### ChipFlowLayout

File: `Custom/ChipFlowLayout.swift`

A wrapping chip layout that automatically flows to the next line when chips exceed the container width. Use for filter chips, tag lists, and amenity badges.

```swift
ChipFlowLayout(chips: categories, selected: $selectedCategory)
```

### PickerSheetView

File: `Custom/PickerSheetView.swift`

A bottom sheet with a scrollable list of options. Use for pickers where the number of options is too large for a segmented control (e.g., selecting a bank for wallet top-up).

---

## Media and Display Components

### AsyncImageCard

File: `Custom/AsyncImageCard.swift`

Async image loading with a shimmer skeleton while the image loads. Handles errors gracefully with a placeholder. Use this instead of a raw `AsyncImage` throughout the app.

```swift
AsyncImageCard(
    imageURL: product.imageURL,
    width: 120,
    height: 120,
    cornerRadius: 12
)
```

### InfiniteCarousel

File: `Custom/InfiniteCarousel.swift`

Auto-scrolling banner carousel with page dots. Loops seamlessly through an array of items. Used on the Home screen for announcement banners.

```swift
InfiniteCarousel(items: announcements) { announcement in
    AnnouncementCardView(announcement: announcement)
}
```

### ShimmerView

File: `Custom/API_UI_Components/Shimmer/ShimmerView.swift`

Standalone shimmer effect. Apply to any placeholder rectangle or shape while content is loading. Used by `AsyncImageCard` internally and available for building custom skeleton screens.

```swift
ShimmerView()
    .frame(width: 120, height: 120)
    .cornerRadius(12)
```

### WebView

File: `Custom/WebView.swift`

`WKWebView` wrapper for rendering web content inside the app. Use for terms of service, help pages, or any content served as HTML.

---

## Feedback Components

### AlertManager

File: `Custom/API_UI_Components/Alert/AlertManager.swift`

Global alert system. Shows a modal dialog with a title, message, and OK button. Call from anywhere — the manager is a singleton.

```swift
AlertManager.shared.showSuccess(title: "Payment Complete", message: "Your order has been placed.")
AlertManager.shared.showError(title: "Insufficient Balance", message: "Please top up your wallet.")
```

Do not use SwiftUI's native `.alert` modifier for error handling — use `AlertManager` for consistency.

### ToastManager

File: `Custom/API_UI_Components/Toast/ToastManager.swift`

Transient toast notification that appears at the top of the screen and auto-dismisses. Use for non-critical confirmations that do not require user acknowledgment.

```swift
ToastManager.shared.show("Added to cart", type: .success)
```

### LoaderManager

File: `Custom/API_UI_Components/Loader/LoaderManager.swift`

Full-screen loading overlay. Shows the `CoffeeLoaderView` animation. Call `show()` before an async operation and `hide()` when it completes.

```swift
LoaderManager.shared.show()
await performAsyncOperation()
LoaderManager.shared.hide()
```

### OfflineBannerModifier

File: `Custom/OfflineBannerModifier.swift`

A `ViewModifier` that shows a sticky "No Internet Connection" banner at the top of the screen when `NetworkMonitor.shared.isConnected` is `false`. Applied at the app root — you do not need to add this to individual screens.

### ComingSoonView

File: `Custom/ComingSoonView.swift`

Placeholder view for features that are planned but not yet implemented. Use in stub screens or tab content that is not ready.

---

## Layout and Navigation Components

### CustomRefreshScrollView

File: `Custom/Scroll/CustomRefreshScrollView.swift`

A `ScrollView` wrapper with pull-to-refresh built in. Use instead of `List` with `.refreshable` when you need a custom scroll container that doesn't use list row insets.

```swift
CustomRefreshScrollView(onRefresh: { await viewModel.reload() }) {
    // scroll content
}
```

### ActionCardButton

File: `Custom/ActionCardButton.swift`

A large tappable card used for primary navigational actions (e.g., "Top Up Wallet", "View Order History"). Renders a title, subtitle, and icon on a `surfacePrimary` background.

### ToolBarButton

File: `Custom/ToolBarButton.swift`

A consistently styled button for use in navigation bar toolbars. Wraps an SF Symbol image with the app's accent color and appropriate hit area.

### MinimumLoadingTime

File: `Custom/MinimumLoadingTime.swift`

A wrapper that enforces a minimum display duration for loading states. Use to prevent flash-of-content when an async operation completes very quickly. A skeleton screen that disappears in 50ms looks broken — this component ensures it shows for at least the specified duration.

```swift
MinimumLoadingTime(minimumSeconds: 0.6, isLoading: $isLoading) {
    // content
}
```

---

## Applying API UI Components

`AlertManager`, `ToastManager`, and `LoaderManager` require their overlay views to be attached to the view hierarchy. This is handled by the `.applyApiUIComponents()` view modifier applied to the `WindowGroup` in `CoffeeCraftApp`. The modifier attaches `AlertManagerView`, `ToastManagerView`, and `LoaderManagerView` as overlays.

Do not call these APIs from a background thread. All calls must come from the main actor.
