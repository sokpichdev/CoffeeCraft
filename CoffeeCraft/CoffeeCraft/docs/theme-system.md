# CoffeeCraft — Theme System

This document explains how the app's theme system works, how to use semantic color tokens in new UI, and how palette switching is propagated across the entire view hierarchy.

---

## Overview

`ThemeManager` manages two independent settings:

1. **Appearance mode** — system, light, or dark
2. **Color palette** — the brand color accent applied throughout the app

Both are persisted with `@AppStorage` (backed by `UserDefaults`) and survive app restarts.

---

## ThemeManager

`ThemeManager` is a singleton `ObservableObject` injected at the app root as an `@EnvironmentObject`.

```
ThemeManager.shared
  ├── theme: AppTheme           (.system | .light | .dark)
  └── palette: ColorPalette     (.brown | .strawberry | .matcha | .oreo)
```

### Setting the Theme

```swift
// From any view that has access to ThemeManager
themeManager.setTheme(.dark)
themeManager.setPalette(.matcha)
```

`setPalette` wraps the assignment in `withAnimation(.easeInOut(duration: 0.35))` for a smooth color transition.

Do not set `themeManager.theme` or `themeManager.palette` directly — use the setter methods so animations and side effects are consistently applied.

---

## AppTheme

The `AppTheme` enum maps to SwiftUI's `ColorScheme?`:

| Case | Maps To | Description |
|---|---|---|
| `.system` | `nil` | Follows the device's system appearance |
| `.light` | `.light` | Forces light mode regardless of system setting |
| `.dark` | `.dark` | Forces dark mode regardless of system setting |

`CoffeeCraftApp` applies the current theme to the root view:

```swift
.preferredColorScheme(themeManager.theme.colorScheme)
```

---

## ColorPalette

The `ColorPalette` enum defines four brand accent themes:

| Case | Description |
|---|---|
| `.brown` | Default coffee brown — warm, classic |
| `.strawberry` | Soft red/pink accent |
| `.matcha` | Muted green accent |
| `.oreo` | Dark charcoal/black and white contrast |

Each palette case provides a full set of `UIColor` values via `dynamicColor(...)` for both light and dark appearances. These values power all semantic color tokens.

---

## Semantic Color Tokens

Always use these tokens in UI code. Never use raw hex values, `UIColor` named colors, or asset catalog color names for any color that should respond to palette or appearance changes.

Tokens are accessed as static properties on `Color`:

### Backgrounds

| Token | Purpose |
|---|---|
| `Color.bgPrimary` | Main app background — used as the root view background |
| `Color.bgSecondary` | Grouped list section backgrounds, drawer backgrounds |

### Surfaces

| Token | Purpose |
|---|---|
| `Color.surfacePrimary` | Cards, sheets, bottom sheets |
| `Color.surfaceSub` | Nested rows, chips, tag pill backgrounds |
| `Color.borderColor` | Dividers, card stroke borders, input field outlines |

### Typography

| Token | Purpose |
|---|---|
| `Color.textPrimary` | Body copy, headings — highest contrast |
| `Color.textSecondary` | Subtitles, section headers, secondary labels |
| `Color.textMuted` | Placeholders, timestamps, muted captions |

### Accents

| Token | Purpose |
|---|---|
| `Color.accentPrimary` | Primary CTA buttons, active tab indicator, toggle fill, links |
| `Color.accentGold` | Rewards, loyalty points, premium tier indicators |

### Gradient Helpers

Pre-built `LinearGradient` values defined in `Color+Ex.swift`:

| Token | Usage |
|---|---|
| `LinearGradient.brandPrimary` | Primary brand gradient for banners and hero sections |
| `LinearGradient.brandGold` | Gold/reward gradient for loyalty card headers |
| `LinearGradient.walletCard` | Wallet balance card gradient |

### UIKit Equivalents

For UIKit components (e.g., `UITextField`, `UINavigationBar` customization), use the `UIColor` extensions:

```swift
UIColor.textPrimaryUI
UIColor.textSecondaryUI
UIColor.accentPrimaryUI
UIColor.bgPrimaryUI
UIColor.surfacePrimaryUI
UIColor.borderColorUI
```

---

## How Palette Switching Works

Palette tokens use `UIColor(dynamicProvider:)` internally. This means each token provides two color values — one for light mode and one for dark mode — and UIKit handles the switch automatically when the device appearance changes.

When the user changes the palette (via `themeManager.setPalette()`), `@Published var palette` fires a change. Since `ThemeManager` is injected as `@StateObject` in `CoffeeCraftApp`, this invalidates the root view.

The root view has `.id(themeManager.palette.rawValue)` applied:

```swift
RootView()
    .id(themeManager.palette.rawValue)
```

Changing `.id()` forces SwiftUI to destroy and recreate the entire view tree, which causes every `Color.accentPrimary` (and all other tokens) to re-evaluate against the new palette. This is intentional — do not remove this modifier.

---

## Adding a New Color

If you need a new named color that is not palette-aware (for example, a one-off status color):

1. Add it to the asset catalog in `Resource/Assets.xcassets` with light and dark variants.
2. Add a static extension on `Color` in `Color+Ex.swift` in the legacy section.

If the color should be palette-aware:

1. Add the new key to the `PaletteTokens` type (or equivalent structure).
2. Define the values for all four palettes in both light and dark.
3. Add a static extension on `Color` that calls `ThemeManager.shared.palette.dynamicColor(\.yourNewKey)`.

---

## User-Facing Settings

The appearance settings are exposed in the Account tab under the appearance settings screen (`AppearanceSettingsView`). Users can:

- Toggle between system, light, and dark mode
- Choose one of the four color palettes

Settings take effect immediately with an animated transition.
