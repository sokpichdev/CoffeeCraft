//
//  Gradients.swift
//  TestSwiftUI
//
//  Created by Sok Pich on 11/28/24.
//

import SwiftUI

struct Gradients: View {
    var body: some View {
//        LinearGradient(colors: [.red, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        
//        LinearGradient(stops: [Gradient.Stop(color: .white, location: 0.45),
//                               Gradient.Stop(color: .black, location: 0.55)
//                              ], startPoint: .top, endPoint: .bottom)
        
//        AngularGradient(colors: [.red, .yellow, .green, .blue, .purple, .red], center: .center)
        
        Text("Your content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.black)
            .background(.indigo.gradient)
    }
}

#Preview {
    Gradients()
}
