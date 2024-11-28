//
//  d11.swift
//  TestSwiftUI
//
//  Created by Sok Pich on 11/28/24.
//
import SwiftUI

struct Colors: View {
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                Color.red
                Color.blue
            }
            Text("Your Content")
                .foregroundStyle(.secondary)
                .padding(50)
                .background(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }
}


#Preview {
    Colors()
}
