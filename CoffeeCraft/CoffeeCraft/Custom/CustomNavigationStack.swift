//
//  CustomNavigationStack.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            content()
        }
        .withAlertManager()
        .withLoaderManager()
        .withToastManager()
    }
}
