//
//  LoadImages.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct LoadImages: View {
    var image: String?
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    var cornerRadius: CGFloat?
    var isFit: Bool = false
    var shadow: CGFloat = 5
    
    @State private var isLoading = true // Tracks if the image is loading
    
    var body: some View {
        // Image
        if let cover = image, let imageURL = URL(string: cover) {
            ZStack {
                
                WebImage(url: imageURL)
                    .onSuccess { image, data, cacheType in
                        DispatchQueue.main.async {
                            isLoading = false
                        }
                    }
                    .onFailure { _ in
                        isLoading = false
                    }
                    .resizable()
                    .aspectRatio(contentMode: isFit ? .fit : .fill)
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .cornerRadius(cornerRadius ?? 10)
                    .shadow(radius: shadow)
                
                if isLoading { // Show loading indicator while the image is loading
                    ProgressView()
                        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                }
            }
        }
    }
    
}
