//
//  Solo.swift
//  RockPaperScissors
//
//  Created by Sok Pich on 11/29/24.
//


import SwiftUI

struct Solo: View {
    let moves = ["🗿", "📄", "✂️"]
    @State private var appMove = Int.random(in: 0..<3)
    @State private var shouldWin = Bool.random()
    @State private var score = 0
    @State private var round = 1
    @State private var gameOver = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.green, .yellow, .purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                if gameOver {
                    VStack {
                        Text("Game Over")
                            .font(.largeTitle)
                        Text("Your final score: \(score)")
                            .font(.title2)
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Round \(round)")
                            .font(.headline)
                            .bold()
                        
                        Text("The app chose:")
                            .font(.title2)
                            .bold()
                        Text(moves[appMove])
                            .font(.system(size: 150))
                            .bold()
                        
                        Text("Your goal is to:")
                            .font(.title2)
                            .bold()
                        Text(shouldWin ? "Win" : "Lose")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(shouldWin ? .green : .red)
                    }
                    
                    
                    HStack(spacing: 20) {
                        ForEach(0..<3) { index in
                            Button(action: {
                                handlePlayerChoice(index)
                            }) {
                                Text(moves[index])
                                    .font(.system(size: 60))
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .bold()
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    
                    Text("Score: \(score)")
                        .font(.title)
                        .bold()
                }
            }
            .padding()
        }
    }

    func handlePlayerChoice(_ playerChoice: Int) {
        let winningMoves = [1, 2, 0] // Rock -> Paper, Paper -> Scissors, Scissors -> Rock
        let losingMoves = [2, 0, 1]  // Rock -> Scissors, Paper -> Rock, Scissors -> Paper

        let correctMove = shouldWin ? winningMoves[appMove] : losingMoves[appMove]

        if playerChoice == correctMove {
            score += 1
        } else {
            score -= 1
        }

        nextRound()
    }

    func nextRound() {
        if round == 10 {
            gameOver = true
        } else {
            round += 1
            appMove = Int.random(in: 0..<3)
            shouldWin.toggle()
        }
    }
}

#Preview {
    Solo()
}
