//
//  ToolBarButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/26/26.
//
import SwiftUI

struct ToolBarButton: ToolbarContent {
    enum ButtonType {
        case icon(String)
        case text(String)
    }

    let placement: ToolbarItemPlacement
    let buttonType: ButtonType
    var tint: Color = .brown
    var font: Font = .headline
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: action) {
                switch buttonType {
                case .icon(let systemName):
                    Image(systemName: systemName)
                        .font(font)

                case .text(let title):
                    Text(title)
                        .font(font)
                }
            }
            .foregroundColor(tint)
        }
    }
}

struct ToolBarProgress: ToolbarContent {

    let placement: ToolbarItemPlacement
    var tint: Color = .brown

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            ProgressView()
                .tint(tint)
        }
    }
}
