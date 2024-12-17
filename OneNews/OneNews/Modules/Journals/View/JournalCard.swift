//
//  JournalCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct JournalCard: View {
    let album: AlbumModel  // Album data for the card
    
    @State private var isLoading = true // Tracks if the image is loading
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // Album Cover
                LoadImages(image: album.cover, maxWidth: 140, maxHeight: 120, isFit: true)
                
                VStack(alignment: .leading, spacing: 5) {
                    // Star Button
                    HStack {
                        Spacer()
                        Button(action: {
                            // Placeholder action for the favorite button
                        }) {
                            Image("Star1")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .padding(.trailing, 10)
                    
                    // Album Name
                    Text(album.name ?? "Unknown")
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    // Issue Info
                    HStack {
                        Image("Calendar")
                            .resizable()
                            .frame(width: 15, height: 15)
                        
                        Text(album.journal?.issueYear ?? "")
                        Spacer()
                        Text("Issue")
                            .fontWeight(.ultraLight)
                        Text(album.journal?.issueNo ?? "")
                    }
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.background)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.optionBtn2, .optionBtn2.opacity(0.5), .optionBtn2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
    }
}
