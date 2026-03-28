import SDWebImageSwiftUI
//
//  AsyncImageCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

struct AsyncImageCard: View {
    let imageURL: String?
    let placeholderText: String = "No Image"
    var isFill: Bool = true
    let height: CGFloat
    let width: CGFloat
    var corner: CGFloat = 15
    var accessibilityLabel: String?
    
    @State private var isURLValid: Bool = false
    private var iconSize: CGFloat { height * 0.35 }
    private var textSize: CGFloat { height * 0.12 }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(Color.textMuted.opacity(0.2))
            
            if !isURLValid || (imageURL ?? "").isEmpty {
                VStack(spacing: height * 0.05) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: iconSize))
                        .foregroundColor(.textMuted)
                    
                    Text(placeholderText)
                        .font(.system(size: textSize))
                        .foregroundColor(.textMuted)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            if let urlString = imageURL, let url = URL(string: urlString), !urlString.isEmpty {
                WebImage(url: url)
                    .onSuccess { _, _, _ in
                        DispatchQueue.main.async { isURLValid = true }
                    }
                    .onFailure { _ in
                        DispatchQueue.main.async { isURLValid = false }
                    }
                    .resizable()
                    .aspectRatio(contentMode: isFill ? .fill : .fit)
                    .frame(maxHeight: height)
                    .frame(maxWidth: width)
                    .clipped()
                    .cornerRadius(corner)
                    .accessibilityHidden(accessibilityLabel == nil)
                    .accessibilityLabel(accessibilityLabel ?? "")
            }
        }
        .frame(height: height)
        .frame(maxWidth: width)
        .cornerRadius(corner)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
