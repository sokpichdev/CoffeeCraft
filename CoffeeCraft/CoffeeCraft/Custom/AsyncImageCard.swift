//
//  AsyncImageCard.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI
import SDWebImageSwiftUI

struct AsyncImageCard: View {
    let imageURL: String?
    let placeholderText: String = "No Image"
    let height: CGFloat
    let width: CGFloat
    var corner: CGFloat = 15
    
    @State private var isURLValid: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(Color.gray.opacity(0.2))
            
            if !isURLValid || (imageURL ?? "").isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text(placeholderText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
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
                    .scaledToFill()
                    .frame(height: height)
                    .frame(maxWidth: width)
                    .clipped()
                    .cornerRadius(corner)
            }
        }
        .frame(height: height)
        .cornerRadius(corner)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
