//
//  ContentView.swift
//  AIChat
//
//  Created by Sok Pich on 5/20/25.
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

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let content: String
}

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []

    private let apiKey = "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"

    func sendMessage(_ text: String) {
        messages.append(ChatMessage(isUser: true, content: text))

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages.map {
                ["role": $0.isUser ? "user" : "assistant", "content": $0.content]
            }
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String
            else { return }

            DispatchQueue.main.async {
                self.messages.append(ChatMessage(isUser: false, content: content.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }.resume()
    }
}

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var input = ""

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                Spacer()
                            }
                        }
                    }
                }.padding()
            }

            HStack {
                TextField("Say something...", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    viewModel.sendMessage(input)
                    input = ""
                }
            }.padding()
        }
    }
}
