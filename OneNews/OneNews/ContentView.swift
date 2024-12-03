//
//  ContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                navigation
                    
                categoryButtons
                Spacer() // Push content to the bottom
                
               showContents
            }
        }
    }
    
    private var navigation: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    // Menu Btn
                }) {
                    Image("Menu")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                }
                Spacer()
                
                Spacer()
                
                HStack(spacing: 5) {
                    Button(action: {
                        // Search Btn
                    }) {
                        Image("Search")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                    }
                    Button(action: {
                        // Star Btn
                    }) {
                        Image("Star")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                    }
                }
            }
            .padding()
            .frame(height: 50)
                    .overlay(
                        Image("title")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                    )
        }
    }

    private var categoryButtons: some View {
        // Categories Tabs
        HStack(spacing: 0) { // No spacing for equal distribution
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
                                .foregroundColor(viewModel.selectedCategoryIndex == index ? .primary : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
    //                    .background(
    //                        selectedCategory == category ? Color.purple.opacity(0.2) : Color.clear
    //                    )
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
        .background(Color(UIColor.systemGray6)) //// Background color for the whole HStack
        .padding(.horizontal, 16)
    }
    
    private var showContents: some View {
        ScrollViewReader { proxy in // to make it scroll back to the id(0)
            ScrollView {
                VStack {
                    let allNews = viewModel.selectedCategoryIndex == 0 ? viewModel.news :
                    viewModel.news.filter { $0.type.rawValue == viewModel.selectedCategoryIndex }
                    
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
//                    ForEach(allNews.dropFirst(), id: \.title) { newsItem in
//                        NavigationLink(destination: ContentDetail(news: newsItem)) {
//                            RegularNewsView(newsItem: newsItem)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }

                    
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
                                otherNews(newsItem: newsItem)
                            case 2:
                                otherNews(newsItem: newsItem)
                            case 3:
                                otherNews(newsItem: newsItem)
                            default:
                                otherNews(newsItem: newsItem)
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

struct LatestNewsView: View {
    let newsItem: NewsModel
    var body: some View {
        // Highlight the latest news item
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
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal, 16)
                .background(Color.gray)
        }
    }
}

struct OldNews: View {
    let newsItem: NewsModel
    var body: some View {
        VStack {
            HStack {
                Text(newsItem.title)
                    .font(.caption)
                Spacer() // push to the left
            }
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal, 16)
                .background(.gray)
        }
    }
}

struct otherNews: View {
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
#Preview {
    ContentView()
}


