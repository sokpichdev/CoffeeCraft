//
//  ComingSoonView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/1/25.
//
import SwiftUI

struct ComingSoonView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var featureName: String = "This feature"
    @State private var rotate = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .scaleEffect(scale)
                .animation(
                    .easeInOut(duration: 3.5)
                        .repeatForever(autoreverses: true),
                    value: rotate
                )
                .animation(
                    .easeInOut(duration: 2.25)
                        .repeatForever(autoreverses: true),
                    value: scale
                )
            
            Text("\(featureName) is coming soon!")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Text("Stay tuned for updates ☕️")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {
                authVM.logout()
            }, label: {
                Text("Logout")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            })
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            rotate.toggle()
            scale = 0.85
        }
    }
}
