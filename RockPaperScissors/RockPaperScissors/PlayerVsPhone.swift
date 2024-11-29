//
//  PlayerVsPhone.swift
//  RockPaperScissors
//
//  Created by Sok Pich on 11/29/24.
//
import SwiftUI

struct Game: View {
    let moves = ["🗿", "📄", "✂️"]
    
    @State private var playerChoice: Int? = nil
    @State private var botChoice: Int? = nil
    
    @State private var playerScore = 0
    @State private var botScore = 0
    
    @State private var round = 1
    @State private var roundResult: String = ""
    @State private var showFinalResult = false
    
    private let maxRounds = 3
    
    var body: some View {
        VStack {
            if showFinalResult {
                finalResultView
            } else {
                gameView
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .green]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            resetGame()
        }
    }
    
    // MARK: - Game View
    var gameView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Round \(round) / \(maxRounds)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Current Scores
            HStack {
                VStack {
                    Text("You")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(playerScore)")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }
                Spacer()
                VStack {
                    Text("Bot")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(botScore)")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            
            // Player and Phone Choices
            HStack {
                VStack {
                    Text("Your Choice")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(playerChoice != nil ? moves[playerChoice!] : "❓")
                        .font(.system(size: 80))
                        .frame(width: 100, height: 100) // Fixed frame for consistent layout
                        .background(Circle().fill(Color.white.opacity(0.2)))
                        .shadow(radius: 5)
                }
                Spacer()
                VStack {
                    Text("Bot's Choice")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(botChoice != nil ? moves[botChoice!] : "❓")
                        .font(.system(size: 80))
                        .frame(width: 100, height: 100) // Fixed frame for consistent layout
                        .background(Circle().fill(Color.white.opacity(0.2)))
                        .shadow(radius: 5)
                }
            }
            
            // Result of the Round
            Text(roundResult)
                .font(.title)
                .bold()
                .foregroundColor(
                    roundResult.contains("Win") ? .green :
                    roundResult.contains("Lose") ? .red :
                    .yellow
                )
                .frame(height: 40) // Fixed height to prevent layout shift
                .padding(.top, 20)
            
            Spacer()
            
            // Player Choices
            HStack(spacing: 30) {
                ForEach(0..<3) { index in
                    Button(action: {
                        playerChose(index)
                    }) {
                        Text(moves[index])
                            .font(.system(size: 50))
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .shadow(radius: 5)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Final Result View
    var finalResultView: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text(botScore > playerScore ? "You Win 🤓" :
                botScore < playerScore ? "You Lose 🤪" :
                "It's a Draw 🤝")
                .font(.title)
                .foregroundColor(
                    botScore > playerScore ? .green :
                    botScore < playerScore ? .red :
                    .yellow
                )
            
            Text("Final Score: \(playerScore) - \(botScore)")
                .font(.headline)
                .foregroundColor(.white)
            
            Button("Play Again") {
                resetGame()
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    // MARK: - Game Logic
    func playerChose(_ choice: Int) {
        playerChoice = choice
        botChoice = Int.random(in: 0..<3)
        
        // Determine winner of the round
        if playerChoice == botChoice {
            roundResult = "It's a Draw 🤝"
        } else if (playerChoice == 0 && botChoice == 2) ||
                  (playerChoice == 1 && botChoice == 0) ||
                  (playerChoice == 2 && botChoice == 1) {
            roundResult = "You Win 🤓"
        } else {
            roundResult = "You Lose 🤪"
            botScore += 1
        }
        
        // Reset choices after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.playerChoice = nil
            self.botChoice = nil
            self.roundResult = ""
            
            // Move to next round or show final result
            if self.round < self.maxRounds {
                self.round += 1
            } else {
                self.showFinalResult = true
            }
        }
    }
    
    func resetGame() {
        playerScore = 0
        botScore = 0
        round = 1
        roundResult = ""
        playerChoice = nil
        botChoice = nil
        showFinalResult = false
    }
}

#Preview {
    Game()
}
