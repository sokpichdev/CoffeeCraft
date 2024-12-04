//
//  ContentDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/3/24.
//
import SwiftUI

struct ContentDetail: View {
    
    let news: NewsModel?
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let news = news {
                    // News Title
                    Text(news.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 16)
                    
                    // Published Date
                    Text("Published Date:")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                    
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            // Share btn
                        }) {
                            Image("Share")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            // Copy link Btn
                        }) {
                            Image("CopyLink")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // Image
                    Image(news.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 380, height: 200)
                        .cornerRadius(10)
                        .clipped() // Ensures no overflow
                        .padding(.horizontal, 16)
                    
                    // Subtitle
                    Text(news.title)
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    // Full Article
                    Text(viewModel.newsDetail)
                        .font(.body)
                        .lineSpacing(10)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                    
                    // Ads
                    VStack(alignment: .leading ,spacing: 10){
                        Text("Advertisement")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                        
                        
                        Image("ads1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 200)
                            .cornerRadius(10)
                            .clipped() // Ensures no overflow
                            .padding(.horizontal, 16)
                    }.padding(.vertical, 10)
                    
                    Text("Recommended News")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                    /*How to show recommended news base on the type content user clicked.*/
                    
                    ForEach(viewModel.filter(news: news), id: \.title) { relatedNewsItem in
                        NavigationLink(destination: ContentDetail(news: relatedNewsItem, viewModel: viewModel)) {
                            LatestNewsView(newsItem: relatedNewsItem)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                    }
                    
                } else {
                    // Fallback when no news is selected
                    Text("No news selected.")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                }
                
                
                Spacer() // Push content to the top
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            
//            .navigationBarItems(leading: NavBar())
        }
//        .navigationBarHidden(true)
    }
}
