//
//  HTMLWebView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 7/21/25.
//
import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let header = """
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system;
                    font-size: 16px;
                    color: #FFFFFF;
                    background-color: transparent;
                }
            </style>
        </head>
        <body>
        """
        
        let footer = "</body>"
        let fullHTML = header + htmlString + footer
        
        uiView.loadHTMLString(fullHTML, baseURL: nil)
    }
}
