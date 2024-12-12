//
//  ContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI

struct NewsView: View {
    
    @ObservedObject var viewModel = NewsViewModel()

    var body: some View {
            VStack {
                
                categoryButtons
                Spacer() // Push content to the bottom
                
                showContents
//                    .background(Color.white)
                
            }
//            .padding(.horizontal, 16)
//            .background(Color(.systemGray5))
//            .background(Color.white)
    }

    private var categoryButtons: some View {
        // Categories Tabs
        HStack(spacing: 5) { // No spacing for equal distribution
            ForEach(viewModel.categories.indices, id: \.self) { index in
                withAnimation(.smooth){
                    CustomOptionButtons(title: viewModel.categories[index], imageName: viewModel.categories[index], isSelected: viewModel.selectedCategoryIndex == index) {
                            viewModel.selectedCategoryIndex = index
                        
                    }
                }
            }
        }
        .frame(height: 80) //// Total height of the tabs
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.letters.opacity(0.0), .letters.opacity(0.0), .letters.opacity(0.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var showContents: some View {
        ScrollViewReader { proxy in // to make it scroll back to the id(0)
            ScrollView {
                VStack(alignment: .leading) {
                    let allNews = viewModel.selectedCategoryIndex == 0 ? viewModel.news :
                    viewModel.news.filter { $0.type.rawValue == viewModel.selectedCategoryIndex }
                    
                    CustomLabel(text: "Lastest news", font: .largeTitle, alignment: .leading)
                        .padding(.horizontal, 16)
                        .id(0)
                    
                    // Latest news
                    if let latestNews = allNews.first {
                        
                        Button(action: {
                            viewModel.selectedNews = latestNews
                            print(viewModel.selectedNews?.title ?? "nil")
                        }) {
                            NavigationLink(destination: ContentDetail(news: latestNews)){
                                LatestNewsView(newsItem: latestNews)
                            }
                            .foregroundStyle(Color.letters)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        Divider()
                            .background(Color.gray)
                            .padding(.horizontal, 16)
                    }
                    
                    // The rest of the news
                    ForEach(allNews.dropFirst(), id: \.title) { newsItem in
                        //                    RegularNewsView(newsItem: newsItem)
                        Button(action: {
                            viewModel.selectedNews = newsItem
                            print(viewModel.selectedNews?.title ?? "nil")
                        }) {
                            NavigationLink(destination: ContentDetail(news: newsItem)){
                                RegularNewsView(newsItem: newsItem)
                            }
                            .foregroundStyle(Color.letters)
                        }
                        .padding(.horizontal, 16)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Old News // example use allNews for now.
                    ForEach(allNews, id: \.title) { newsItem in
                        NavigationLink(destination: ContentDetail(news: newsItem)){
                            OldNews(newsItem: newsItem)
                        }
                        .foregroundStyle(Color.black)
                    }
                    .padding(.horizontal, 16)
                    
                    // Section Football
                    ForEach(allNews, id: \.title) { newsItem in
                        NavigationLink(destination: ContentDetail(news: newsItem)) {
                            switch newsItem.type.rawValue {
                            case 1:
                                OtherNews(newsItem: newsItem)
                            case 2:
                                OtherNews(newsItem: newsItem)
                            case 3:
                                OtherNews(newsItem: newsItem)
                            default:
                                OtherNews(newsItem: newsItem)
                            }
                        }
                    }
                    .foregroundStyle(.letters)
                }
            }
            .onChange(of: viewModel.selectedCategoryIndex) { _ in
                withAnimation {
                    proxy.scrollTo(0)
                    //
                }
            }
        }
//        .padding(16)
        
    }
}



#Preview {
    NewsView()
}


