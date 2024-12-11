//
//  ContentDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/3/24.
//
import SwiftUI

struct ContentDetail: View {
    
    let news: NewsModel?
    @ObservedObject var viewModel = NewsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let news = news {
                    // News Title
                    Text(news.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    // Published Date
                    Text("Published Date:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    
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
                    
                    // Image
                    Image(news.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .cornerRadius(10)
                        .clipped() // Ensures no overflow
                    
                    // Subtitle
                    Text(news.title)
                        .font(.subheadline)
                    
                    Divider()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    // Full Article
                    Text(viewModel.newsDetail)
                        .font(.body)
                        .lineSpacing(10)
                        .multilineTextAlignment(.leading)
                    
                    // Ads
                    VStack(alignment: .leading ,spacing: 10){
                        CustomLabel(text: "Advertisement")
                        
                        
                        Image("ads1")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .cornerRadius(10)
                            .clipped() // Ensures no overflow
                    }.padding(.vertical, 10)
                    
                    CustomLabel(text: "Recommended News")
                    
                    ForEach(viewModel.filter(news: news), id: \.title) { relatedNewsItem in
                        NavigationLink(destination: ContentDetail(news: relatedNewsItem, viewModel: viewModel)) {
                            OtherNews(newsItem: relatedNewsItem)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, -16)
                        Divider()
                    }
                    
                } else {
                    // Fallback when no news is selected
                    Text("No news selected.")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                
                Spacer() // Push content to the top
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            
//            .navigationBarItems(leading: NavBar())
        }
        .padding(.horizontal, UIScreen.main.bounds.width < 375 ? 10: 16)
//        .navigationBarHidden(true)
    }
}

#Preview {
    ContentDetail(news: NewsModel.init(image: "CR7ScoredHatTrick", title: "CR7 scores hat-trick", type: .football))
}
