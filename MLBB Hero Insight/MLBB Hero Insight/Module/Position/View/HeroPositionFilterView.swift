//
//  HeroPositionFilterView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//

import SwiftUI

struct HeroPositionFilterView: View {
    @Binding var lane: String
    @Binding var role: String
    
    var onApply: () -> Void
    var onReset: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lanes")) {
                    Picker("Lane", selection: $lane) {
                        ForEach(["all", "exp", "mid", "roam", "jungle", "gold"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                }
                Section(header: Text("Roles")) {
                    Picker("Role", selection: $role) {
                        ForEach(["all", "tank", "fighter", "ass", "mage", "mm", "supp"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                }
            }
            .navigationTitle("Filter Positions")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        onReset()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
