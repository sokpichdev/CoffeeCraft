//
//  RegularNewsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct RegularNewsView: View {
    let newsItem: NewsModel
    var body: some View {
        VStack {
            HStack {
                Image(newsItem.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 70)
                    .cornerRadius(10)
                    .padding(.trailing, 10)
                
                Text(newsItem.title)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
//                    .lineLimit(nil)  //No limit on the number of lines
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                
                Spacer()
            }
//            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal, 16)
                .background(Color.gray)
        }
//        .padding(.horizontal, 16)
    }
}
