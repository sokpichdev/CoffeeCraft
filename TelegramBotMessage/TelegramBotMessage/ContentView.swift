//
//  ContentView.swift
//  TelegramBotMessage
//
//  Created by Sok Pich on 5/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


struct TelegramSenderView: View {
    @State private var messageText: String = ""
    @State private var isSending = false
    @State private var resultMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter your message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    Task {
                        isSending = true
                        resultMessage = nil
                        let success = await sendTelegramMessage(text: messageText)
                        isSending = false
                        resultMessage = success ? "✅ Sent!" : "❌ Failed to send."
                        messageText = ""
                    }
                }) {
                    Text(isSending ? "Sending..." : "Send to Telegram")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isSending || messageText.isEmpty)

                if let resultMessage = resultMessage {
                    Text(resultMessage)
                        .foregroundColor(resultMessage.contains("✅") ? .green : .red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Telegram Bot Sender")
        }
    }

    // MARK: - Send Telegram Message
    func sendTelegramMessage(text: String) async -> Bool {
        let botToken = "7822237422:AAEgwP5kvsn6swofqEiPjUlwSagY7rqx-Ug"
        let chatID = "-1002466493552"

        let encodedMessage = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage?chat_id=\(chatID)&text=\(encodedMessage)"

        guard let url = URL(string: urlString) else { return false }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Error sending message:", error)
        }

        return false
    }
}
