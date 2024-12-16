//
//  LatestNewsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct LatestNewsView: View {
    let newsItem: NewsModel
    var body: some View {
        // Highlight the latest news item
        VStack(alignment: .leading) {
            Image(newsItem.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 200) // Larger frame for the latest news
                .cornerRadius(10)
                .clipped() // Ensures no overflow
                .padding(.bottom, 10) // Space between the latest and other news
            
            Text(newsItem.title)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(2) // Limit lines for small screens
                .minimumScaleFactor(0.75) // Shrink text to fit smaller widths

        }
//        .padding(.horizontal, 16)
        .padding(.bottom, UIScreen.main.bounds.width < 375 ? 5 : 10)
        .padding(.horizontal, UIScreen.main.bounds.width < 375 ? 10: 16)

    }
}
