//
//  OldNews.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct OldNews: View {
    let newsItem: NewsModel
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(newsItem.title)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                Spacer() // push to the left
            }
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal, 16)
                .background(.gray)
        }
    }
}
