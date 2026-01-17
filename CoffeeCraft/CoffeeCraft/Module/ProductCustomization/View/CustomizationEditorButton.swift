//
//  CustomizationEditorButton.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//
import SwiftUI

struct CustomizationEditorButton: View {
    @Binding var customizations: [CustomizationCategory]
    @State private var showEditor = false
    
    var totalOptions: Int {
        customizations.reduce(0) { $0 + $1.options.count }
    }
    
    var body: some View {
        Button(action: {
            showEditor = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.brown.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.brown)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Customizations")
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                        .font(.headline)
                    
                    if customizations.isEmpty {
                        Text("No customizations added")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Text("\(customizations.count)")
                                .fontWeight(.semibold)
                            Text("categories •")
                            Text("\(totalOptions)")
                                .fontWeight(.semibold)
                            Text("options")
                        }
                        .font(.caption)
                        .foregroundColor(.brown)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color.brown)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showEditor) {
            CustomizationEditorView(customizations: $customizations)
        }
    }
}
