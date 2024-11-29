//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Sok Pich on 11/29/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Title
                Text("Rock Paper Scissors")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 50)

                // Game Options
                VStack(spacing: 20) {
                    NavigationLink(destination: Solo()) {
                        Text("Play Solo Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    NavigationLink(destination: Game()) {
                        Text("Play Against Bot")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
                
                // Footer
                Text("Choose your mode and start playing!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
            }
            .navigationBarTitle("Game Center", displayMode: .inline)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    ContentView()
}
