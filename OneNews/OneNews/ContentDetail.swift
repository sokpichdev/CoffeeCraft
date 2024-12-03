//
//  ContentDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/3/24.
//
import SwiftUI

struct ContentDetail: View {
    let newDetail = """
                    Cristiano Ronaldo has made football history once again by becoming the all-time top scorer in European leagues, a record that underscores his extraordinary career and remarkable consistency. 
                    
                    The Portuguese superstar achieved this historic milestone in style, scoring a sensational hat trick during a crucial match. This feat is the result of years of relentless hard work, discipline, and a never-ending hunger for success. 
                    
                    Over his illustrious career, Ronaldo has represented some of Europe’s most iconic clubs, including Manchester United, Real Madrid, and Juventus, netting goals across the Premier League, La Liga, and Serie A.
                        
                    Each goal tells the story of his evolution as a player, from a promising young talent at Sporting Lisbon to a global icon. His contributions have not only brought trophies and glory to his teams but also inspired countless fans around the world. 
                    
                    This latest record is yet another chapter in the legendary story of a player often regarded as one of the greatest in football history. Celebrated for his exceptional fitness, technical ability, and leadership, Ronaldo’s achievements continue to cement his status as an enduring symbol of excellence in the beautiful game.
                    """
    
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
                    Text(newDetail)
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
                    
                    let relatedNews = viewModel.news.filter {
                       $0.type == news.type && $0.title != news.title
                   }
                    
                    ForEach(relatedNews, id: \.title) { relatedNewsItem in
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
        }
    }
}
