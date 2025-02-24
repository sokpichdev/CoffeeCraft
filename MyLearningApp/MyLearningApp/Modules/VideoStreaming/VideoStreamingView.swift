//
//  VideoStreamingView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/20/25.
//

import SwiftUI
import AVKit
import WebKit

struct VideoStreamingView: View {
    @State private var videoURL: String = "" {
        didSet { loadVideo() } // Auto-load video on text change
    }
    @State private var player: AVPlayer? = nil
    @State private var youtubeVideoID: String? = nil
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // URL Input Field with Clear Button
                HStack {
                    TextField("Paste video link here...", text: $videoURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    if !videoURL.isEmpty {
                        Button(action: {
                            videoURL = "" // Clear text field
                            resetPlayer()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding()

                // Play Button
                Button(action: loadVideo) {
                    Text("Play Video")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)

                // Video Player (Direct URLs)
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                }

                // YouTube Player
                if let youtubeID = youtubeVideoID {
                    YouTubePlayerView(videoID: youtubeID)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                }

                // Error Message
                if showError {
                    Text("Invalid or unsupported video URL.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Video Player")
        }
    }

    /// Loads the video from the provided URL
    private func loadVideo() {
        guard let url = URL(string: videoURL), url.scheme == "https" else {
            resetPlayer()
            return
        }

        if let videoID = extractYouTubeID(from: videoURL) {
            youtubeVideoID = videoID
            player = nil
            showError = false
        } else if videoURL.hasSuffix(".mp4") {
            player = AVPlayer(url: url)
            youtubeVideoID = nil
            showError = false
        } else {
            resetPlayer()
        }
    }

    /// Extracts the YouTube video ID from a URL
    private func extractYouTubeID(from url: String) -> String? {
        let patterns = [
            "https?://(?:www\\.)?youtube\\.com/watch\\?v=([\\w-]+)",
            "https?://(?:www\\.)?youtu\\.be/([\\w-]+)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }

    /// Resets the player and clears any errors
    private func resetPlayer() {
        player = nil
        youtubeVideoID = nil
        showError = false
    }
}

/// WebView for displaying YouTube videos
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let embedURL = "https://www.youtube.com/embed/\(videoID)"
        webView.load(URLRequest(url: URL(string: embedURL)!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
