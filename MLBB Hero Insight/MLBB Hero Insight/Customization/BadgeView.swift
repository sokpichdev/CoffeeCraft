//
//  BadgeView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 7/21/25.
//
import SwiftUI

struct BadgeView: View {
    let title: String?
    let iconURL: String?
    let background: Color
    var body: some View {
        HStack(spacing: 4) {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                if url.pathExtension.lowercased() == "svg" {
                    SVGImageView(url: url)
                        .frame(width: 28, height: 28)
                } else {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(width: 20, height: 20)
                }
            }
            
            Text(title ?? "")
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background)
        .cornerRadius(6)
    }
}
