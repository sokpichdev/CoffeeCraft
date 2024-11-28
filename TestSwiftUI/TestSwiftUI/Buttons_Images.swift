//
//  Buttons_Images.swift
//  TestSwiftUI
//
//  Created by Sok Pich on 11/28/24.
//

import SwiftUI

struct Buttons: View {
    var body: some View {
        VStack {
            Button("Button 1") {}
                .buttonStyle(.bordered)
            
            Button("Button 2", role: .destructive) {}
                .buttonStyle(.bordered)
            
            Button("Button 3", role: .cancel) {}
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            
            Button("Button 4", role: .destructive) {}
                .buttonStyle(.borderedProminent)
            
            Button {
                print("Button was tapped")
            } label: {
                Text("Tap me!")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.red)
            }
            Image(systemName: "car.fill")
                .foregroundStyle(.red)
                .font(.largeTitle)
            
            Button{ print("Button was tapped")
            } label: {
                Image(systemName: "trash").font(.largeTitle)
            }
            
            Button("Edit", systemImage: "pencil") {
                print("Edit button was tapped")
            }.font(.largeTitle)
            
            Button {
                print("button was tapped")
            } label: {
                Label("Edit", systemImage: "pencil.fill")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.red)
                    .font(.largeTitle)
            }
        }
        
    }
    func executeDelete() {
        print("Now deleting...")
    }
}
struct AlertMessage: View {
    @State private var showingAlert = false
    
    var body: some View {
        Button("Show alert") {
            showingAlert = true
        }
        .alert("Important message", isPresented: $showingAlert) {
            Button("Delete", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please read this.")
        }
    }
}
#Preview {
    AlertMessage()
}
