//
//  RecommendedView.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI
import SDWebImageSwiftUI

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
                HStack(spacing: 10) {
                    if !recommendedVM.recommended.isEmpty {
                        ForEach(recommendedVM.recommended, id: \.id) { recommended in
                            
                            NavigationLink {
                                JournalDetailView(ablumID: recommended.albumID ?? 0, issueYear: recommended.issueYear ?? "", issueNo: recommended.issueNo ?? "", albumTitle: recommended.album?.name ?? "")
                            } label: {
                                ZStack(alignment: .bottom) {
                                    
                                    LoadImages(image: recommended.attachments, maxWidth: 120, maxHeight: 145, cornerRadius: 10, shadow: 5)
                                    
                                    LinearGradient(// Black overlay with content
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
                .padding(.horizontal, 16)
            }
            .frame(height: 145)
        }
    }
}
