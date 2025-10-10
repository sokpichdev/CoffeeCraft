//
//  TelegramNotifier.swift
//  ScanTracking
//
//  Created by Sok Pich on 10/10/25.
//
import Foundation

struct TelegramNotifier {
    static let botToken = "8477769591:AAHcNU1ZsaVSLBdgUQ3NqR4G4KB3sHJtHr8"
    static let chatId = "1057459847"

    static func send(message: String) {
        guard let url = URL(string: "https://api.telegram.org/bot\(botToken)/sendMessage") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "chat_id": chatId,
            "text": message
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            // You can handle response here if needed
        }.resume()
    }
}
