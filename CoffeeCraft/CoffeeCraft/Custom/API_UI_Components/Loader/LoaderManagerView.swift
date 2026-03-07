//
//  LoaderManagerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI

struct LoaderManagerView: View {
    @ObservedObject private var loaderManager = LoaderManager.shared
    
    var body: some View {
        if loaderManager.isLoading {
            Group {
                ZStack {
                    // Dim background
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    CoffeeLoaderView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}
