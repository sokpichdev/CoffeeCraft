//
//  OtherNews.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct OtherNews: View {
    let newsItem: NewsModel
    var body: some View {
        VStack {
            Image(newsItem.image)
                .resizable()
                .scaledToFill()
                .frame(width: 380, height: 200) // Larger frame for the latest news
                .cornerRadius(10)
                .clipped() // Ensures no overflow
                .padding(.bottom, 10) // Space between the latest and other news
            
            Text(newsItem.title)
                .font(.title3) // Larger font for emphasis
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
        }
    }
}
