//
//  View+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//

import SwiftUI

// MARK: - CornerRadius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Navigation
extension View {
    // MARK: - Function Overloading
    func customNavigationBar(_ title: String, displayMode: NavigationBarItem.TitleDisplayMode = .inline, hideBackBtn: Bool = true
    ) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
            .navigationBarBackButtonHidden(hideBackBtn)
    }
    
    func customNavigationBar<T: ToolbarContent>(
        _ title: String,
        displayMode: NavigationBarItem.TitleDisplayMode = .inline,
        hideBackBtn: Bool = true,
        @ToolbarContentBuilder toolbar: () -> T
    ) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
            .navigationBarBackButtonHidden(hideBackBtn)
            .toolbar {
                toolbar()
            }
    }
}

extension ToolBarButton {
    // preconfigured back button
    static func back(_ action: @escaping () -> Void) -> ToolBarButton {
        ToolBarButton(
            placement: .topBarLeading,
            buttonType: .icon("chevron.left"),
            action: action
        )
    }
}
