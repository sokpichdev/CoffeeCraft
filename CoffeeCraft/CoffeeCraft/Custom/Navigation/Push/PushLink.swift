//
//  PushLink.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/19/26.
//
import SwiftUI
/* ============================================================
// MARK: - PushLink
// ============================================================
 A drop-in replacement for NavigationLink that works with our
 custom pushScreen environment instead of SwiftUI's NavigationStack
 destination system.

 Callers never need to:
   • Declare @Environment(\.pushScreen) var push
   • Wrap destinations in AnyView manually

 Usage mirrors NavigationLink exactly:
   PushLink {
       DetailView(item: item)
   } label: {
       ItemCardView(item: item)
   }

 // ============================================================
 // MARK: - When to use PushLink vs push() directly
 // ============================================================

 Use PushLink when:
   • The label is a plain view with no interactive elements inside
     (Text, Image, custom card views, rows that are not Buttons)

     ✅ PushLink { DetailView() } label: { ItemCardView() }
     ✅ PushLink { DetailView() } label: { Text("Go") }

 Use @Environment(\.pushScreen) var push directly when:
   • The component already contains a Button internally — nesting
     PushLink (a Button) inside another Button causes the tap to
     be swallowed and navigation will not fire.

     ✅ RowInSectionView(title: "Favorites") { push(AnyView(FavoriteView())) }
     ✅ Toolbar or context menu actions — these are not SwiftUI views
        so PushLink cannot be used as the tap target at all.

 Never:
   • Nest PushLink inside a component that already has a Button.
   • Call push() manually when a PushLink would work — PushLink
     handles AnyView wrapping and the shared navigation lock for you.
   • Use NavigationLink — it bypasses the custom transition animator.
// ============================================================ */

struct PushLink<Destination: View, Label: View>: View {

    // Read the push action from the environment internally so
    // no parent view ever needs to declare or pass it down manually.
    @Environment(\.pushScreen) private var push

    // Built lazily so the destination view is only created when
    // the button is tapped — not on every render of the parent.
    let destination: () -> Destination

    // The visible tappable content — any view the caller provides.
    let label: () -> Label

    init(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = destination
        self.label = label
    }
    
    // When the destination depends on the value (the common case),
    // accept the value and a mapping closure that builds the view from it.
    init<Value>(
        value: Value,
        @ViewBuilder destination: @escaping (Value) -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = { destination(value) }
        self.label = label
    }

    var body: some View {
        Button(action: {
            // Wrap in AnyView here — the one and only place in the codebase
            // that needs to know about type erasure for navigation.
            push(AnyView(destination()))
        }, label: {
            label()
        })
        // Plain style so the label renders exactly as designed,
        // without any default Button chrome (highlight, tint, etc.).
        .buttonStyle(.plain)
    }
}
