//
//  RecommendedView.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct RecommendedView: View {
    @StateObject var recommendedVM = RecommendedViewModel()
    
    var body: some View {
        VStack {
            recommended
            Spacer()
        }
        .onAppear {
            recommendedVM.fetchJournals()
        }
    }
    private var recommended: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) { // Spacing between images
                    // Check if the journals array is not empty
                    if !recommendedVM.recommended.isEmpty {
                        ForEach(recommendedVM.recommended, id: \.id) { recommended in
                            
                            NavigationLink(destination: JournalDetail(ablumID: recommended.id ?? 2, issueYear: recommended.issueYear ?? "")) {

                                ZStack(alignment: .bottom) {
                                    // Image
                                    if let coverURL = recommended.attachments, let url = URL(string: coverURL) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 120)
                                                .frame(height: 145)
                                                .shadow(radius: 2)
                                                .cornerRadius(15)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 120)
                                                .frame(height: 145)
                                                .cornerRadius(15)
                                        }
                                    }
                                    
                                    // Black overlay with content
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .bottom, endPoint: .center)
                                    
                                    VStack(alignment: .leading) {
                                        Text(recommended.album?.name ?? "Unknown")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text("\(recommended.issueYear ?? "Unknown") - \(recommended.issueNo ?? "0")")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(1))
                                    }
                                    .padding(8)
                                    .frame(maxWidth: 120, alignment: .leading)
                                    .background(Color.black.opacity(0.5))
                                }
                                .cornerRadius(15)
                            }
                            
                        }
                    }
                }
            }
            .frame(height: 145)
        }
    }
}
