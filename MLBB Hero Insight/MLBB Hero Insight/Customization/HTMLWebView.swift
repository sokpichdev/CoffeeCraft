//
//  HTMLWebView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 7/21/25.
//
import SwiftUI
import WebKit
struct DynamicHTMLView: View {
    let htmlContent: String
    @State private var contentHeight: CGFloat = 100 // Initial height
    
    var body: some View {
        HTMLWebView(htmlString: htmlContent, contentHeight: $contentHeight)
            .frame(height: contentHeight)
            .background(Color.clear)
    }
}

struct HTMLWebView: UIViewRepresentable {
    let htmlString: String
    @Binding var contentHeight: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: -apple-system;
                        font-size: 16px;
                        background-color: transparent !important;
                        margin: 0;
                        padding: 0;
                        word-wrap: break-word;
                    }
                </style>
            </head>
            <body>
                \(htmlString)
            </body>
        </html>
        """
        
        uiView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLWebView
        
        init(parent: HTMLWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Get the actual content height after rendering
            webView.evaluateJavaScript("document.body.scrollHeight") { (height, error) in
                DispatchQueue.main.async {
                    if let height = height as? CGFloat {
                        // Add small padding to prevent cutoff
                        self.parent.contentHeight = height + 10
                    }
                }
            }
        }
    }
}
