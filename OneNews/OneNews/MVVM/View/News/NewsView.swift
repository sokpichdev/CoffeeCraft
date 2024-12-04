//
//  ContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI

struct NewsView: View {
    
    @ObservedObject var viewModel = ContentViewModel()
    
    let tabBarItems = ["News","Journals","Sports","Lottery","Products"]
    @State var selectedTabBarIndex: Int = 0
        // I want to click the buttons in the tab bar and it goes to the other views baseds on he index 
    var body: some View {
            VStack{
                
                categoryButtons
                Spacer() // Push content to the bottom
                
                showContents.background(Color(UIColor.systemGray6))
                
//                TabBar()
            }
    }
    
    private var categoryButtons: some View {
        // Categories Tabs
        HStack(spacing: 3) { // No spacing for equal distribution
            ForEach(viewModel.categories.indices, id: \.self) { index in
                withAnimation(.smooth){
                    Button(action: {
                        viewModel.selectedCategoryIndex = index
                    }) {
                        VStack(spacing: 5) {
                            Image(viewModel.selectedCategoryIndex == index ? "Clicked\(viewModel.categories[index])" : viewModel.categories[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(viewModel.categories[index])
                                .font(.caption)
                                .foregroundColor(viewModel.selectedCategoryIndex == index ? .main : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        //                    .background(
                        //                        selectedCategory == category ? Color.purple.opacity(0.2) : Color.clear
                        //                    )
                        .background(LinearGradient(gradient: Gradient(colors: [Color(.systemGray4), .white, Color(.systemGray5)]), startPoint: .top, endPoint: .bottom)) // Background gradient
                        .shadow(radius: 10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.selectedCategoryIndex == index ? Color.main: Color.clear, lineWidth: 2) // add border.
                        )
                    }
                }
            }
        }
        .frame(height: 80) //// Total height of the tabs
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemGray6))
    }
    
    private var showContents: some View {
        ScrollViewReader { proxy in // to make it scroll back to the id(0)
            ScrollView {
                VStack {
                    let allNews = viewModel.selectedCategoryIndex == 0 ? viewModel.news :
                    viewModel.news.filter { $0.type.rawValue == viewModel.selectedCategoryIndex }
                    
                    // Latest news
                    if let latestNews = allNews.first {
                        
                        Button(action: {
                            viewModel.selectedNews = latestNews
                            print(viewModel.selectedNews?.title ?? "nil")
                        }) {
                            NavigationLink(destination: ContentDetail(news: latestNews)){
                                LatestNewsView(newsItem: latestNews)
                            }.foregroundStyle(.black)
                        }.buttonStyle(PlainButtonStyle())
                            .id(0)
                        
                        Divider()
                            .padding(.horizontal, 16)
                            .background(Color.gray)
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
                            .foregroundStyle(Color.black)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Old News // example use allNews for now.
                    ForEach(allNews, id: \.title) { newsItem in
                        NavigationLink(destination: ContentDetail(news: newsItem)){
                            OldNews(newsItem: newsItem)
                        }
                        .foregroundStyle(Color.black)
                    }.padding(.vertical, 10)
                    
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
                            }                    }
                    }
                    .foregroundStyle(.black)
                }.padding(.horizontal, 16)
            }
            .onChange(of: viewModel.selectedCategoryIndex) { _ in
                withAnimation {
                    proxy.scrollTo(0)
                    //
                }
            }
        }
    }
}



#Preview {
    NewsView()
}


