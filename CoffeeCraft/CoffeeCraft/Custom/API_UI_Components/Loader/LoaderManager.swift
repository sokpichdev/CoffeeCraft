//
//  LoaderManager.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI

@MainActor
class LoaderManager: ObservableObject {
    static let shared = LoaderManager()
    
    @Published var isLoading: Bool = false
    
    private init() {}

    func showLoading(autoHide: Bool = false, delay: Double = 30) {
        isLoading = true
        
        if autoHide {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                hideLoading()
            }
        }
    }
    
    func hideLoading() {
        isLoading = false
    }
}