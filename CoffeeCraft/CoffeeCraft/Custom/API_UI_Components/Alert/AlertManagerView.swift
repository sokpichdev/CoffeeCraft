//
//  AlertManagerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/30/26.
//
import SwiftUI

struct AlertManagerView: View {
    @ObservedObject private var alertManager = AlertManager.shared
    
    var body: some View {
        Group {
            if alertManager.showAlert, let alert = alertManager.currentAlert {
                CoffeeAlertView(alertModel: alert) {
                    alertManager.dismiss()
                }
                .transition(.opacity)
            }
        }
    }
}
