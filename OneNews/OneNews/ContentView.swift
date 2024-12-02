//
//  ContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedCategoryIndex: Int = 0
    @State private var newsImage: String = ""
    
    let categories = ["All", "Football", "Basketball", "Lottery"]
    
    let newsList: [NewsModel] = [
        // Football
        NewsModel(image: "barceVSmancity", title: "Champions League: Barcelona and Manchester City Advance to Quarterfinals", type: .football),
        NewsModel(image: "CR7ScoredHatTrick", title: "Cristiano Ronaldo Becomes All-Time Top Scorer in European Leagues", type: .football),
        NewsModel(image: "ChelseaOVerManUnited", title: "Premier League: Chelsea Triumphs Over Manchester United in Thrilling Match", type: .football),
        NewsModel(image: "messi", title: "Lionel Messi Announces Departure from Paris Saint-Germain After 2023 Season", type: .football),
        NewsModel(image: "fifa", title: "FIFA World Cup: France and Argentina Prepare for Finals Showdown", type: .football),
        NewsModel(image: "sevilla", title: "UEFA Europa League: Sevilla Clinches Title After Dramatic Penalty Shootout", type: .football),
        NewsModel(image: "BayernConsecutiveWins", title: "Bundesliga: Bayern Munich Extends League Dominance with Consecutive Wins", type: .football),

        // Basketball
        NewsModel(image: "LeBronAllTime", title: "LeBron James Breaks All-Time Scoring Record in a Thrilling Victory", type: .basketball),
        NewsModel(image: "GoldenState", title: "Golden State Warriors Dominate the Lakers in a High-Scoring Game", type: .basketball),
        NewsModel(image: "StephenCurry", title: "Stephen Curry Shines with Triple-Double as Warriors Clinch Playoff Spot", type: .basketball),
        NewsModel(image: "Giannis", title: "Giannis Antetokounmpo Leads Bucks to Victory in Game 7 of Playoffs", type: .basketball),
        NewsModel(image: "nbafinal", title: "NBA Finals: Miami Heat Takes Game 1 in a Stunning Overtime Battle", type: .basketball),
        NewsModel(image: "KobeBryant", title: "Kevin Durant Reaches 30,000 Career Points in Spectacular Performance", type: .basketball),
        NewsModel(image: "luka", title: "Luka Dončić Sets Record for Most Points in a Single Game This Season", type: .basketball),

        // Lottery
        NewsModel(image: "winLottery", title: "Record-Breaking Jackpot: Powerball Hits $1.5 Billion", type: .lottery),
        NewsModel(image: "mega", title: "Mega Millions Winner Takes Home $750 Million After Tax Deductions", type: .lottery),
        NewsModel(image: "lotteryInvestigate", title: "Lottery Officials Investigate Claims of Fraudulent Winning Ticket", type: .lottery),
        NewsModel(image: "localman", title: "Local Man Claims Second Lottery Win in Two Years, Becomes a Millionaire Again", type: .lottery),
        NewsModel(image: "Statelottery", title: "State Lottery Announces Additional Weekly Drawings Starting Next Month", type: .lottery),
        NewsModel(image: "plannoshare", title: "Group of Co-Workers Wins $10 Million Lottery Jackpot, Plans to Share", type: .lottery),
        NewsModel(image: "mysterywinnner", title: "Mystery Winner Comes Forward to Claim $500 Million Jackpot After Two Weeks", type: .lottery)
    ].shuffled()
    
    var body: some View {
        NavigationView {
            VStack{
                navigation
                    
                categoryButtons
                Spacer() // Push content to the bottom
                
//                if selectedCategory == "Football" {
                    footballContent
//                } else if selectedCategory == "Basketball" {
//                    basketballContent
//                } else if selectedCategory == "Lottery" {
//                    lotteryContent
//                } else {
//                    allNewsContent
//                }
            }
        }
    }
    
    private var navigation: some View {
            VStack(spacing: 0) {
            // nav bar
            HStack {
                Button(action: {
                    // Menu Btn
                }) {
                    Image("Menu")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text("News")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color(UIColor.black))
                
                Spacer()
                
                HStack(spacing: 5) {
                    Button(action: {
                        // Search Btn
                    }) {
                        Image("Search")
                            .frame(width: 30, height: 30, alignment: .trailing)
                            .foregroundStyle(.gray)
                    }
                    Button(action: {
                        // Star Btn
                    }) {
                        Image("Star")
                            .frame(width: 30, height: 30, alignment: .trailing)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
            .frame(height: 50)
            .background(Color(UIColor.systemGray5))
        }
    }
    private var categoryButtons: some View {
        // Categories Tabs
        HStack(spacing: 0) { // No spacing for equal distribution
            ForEach(categories.indices, id: \.self) { index in
                Button(action: {
                    selectedCategoryIndex = index
                }) {
                    VStack(spacing: 5) {
                        Image(selectedCategoryIndex == index ? "Clicked\(categories[index])" : categories[index])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text(categories[index])
                            .font(.caption)
                            .foregroundColor(selectedCategoryIndex == index ? .primary : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
//                    .background(
//                        selectedCategory == category ? Color.purple.opacity(0.2) : Color.clear
//                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedCategoryIndex == index ? Color.primary : Color.clear, lineWidth: 2) // add border.
                    )
                }
            }
        }
        .frame(height: 80) //// Total height of the tabs
        .background(Color(UIColor.systemGray6)) //// Background color for the whole HStack
    }
    private var allNewsContent: some View {
        ScrollView {
            VStack {
                // Highlight the latest news item (the first in the list)
                if let latestNews = newsList.first {
                    VStack {
                        Image(latestNews.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 200) // Larger frame for emphasis
                            .cornerRadius(10)
                            .clipped() // Ensures no overflow
                            .padding(.bottom, 10) // Space between the latest and other news
                        
                        Text(latestNews.title)
                            .font(.title3) // Larger font for emphasis
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                    }
                    Divider()
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                }
                
                // The rest of the news
                ForEach(newsList.dropFirst(), id: \.title) { newsItem in
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
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Divider()
                            .padding(.horizontal, 10)
                            .background(Color.gray)
                    }
                }
            }
            .padding(.horizontal) // Add padding around the entire content
        }
    }

    
    private var footballContent: some View {
        ScrollView {
            VStack {
                // Get the filtered football news
                let footballNews = selectedCategoryIndex == 0 ? newsList :
                newsList.filter { $0.type.rawValue == selectedCategoryIndex }
                
                if let latestNews = footballNews.first {
                    // Highlight the latest news item
                    VStack {
                        Image(latestNews.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 200) // Larger frame for the latest news
                            .cornerRadius(10)
                            .clipped() // Ensures no overflow
                            .padding(.bottom, 10) // Space between the latest and other news
                        
                        Text(latestNews.title)
                            .font(.title3) // Larger font for emphasis
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                    }
                    Divider()
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                }
                
                // The rest of the news
                ForEach(footballNews.dropFirst(), id: \.title) { newsItem in
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
//                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Divider()
                            .padding(.horizontal, 10)
                            .background(Color.gray)
                    }
                }
            }
            .padding(.horizontal) // Add padding around the entire content
        }
    }
    private var basketballContent: some View {
        ScrollView {
            VStack {
                // Get the filtered football news
                let basketballNews = newsList.filter { $0.type == .basketball }
                
                if let latestNews = basketballNews.first {
                    // Highlight the latest news item
                    VStack {
                        Image(latestNews.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 200) // Larger frame for the latest news
                            .cornerRadius(10)
                            .clipped() // Ensures no overflow
                            .padding(.bottom, 10) // Space between the latest and other news
                        
                        Text(latestNews.title)
                            .font(.title3) // Larger font for emphasis
                            .fontWeight(.bold)
//                            .multilineTextAlignment(.leading)
                    }
                    Divider()
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                }
                
                // The rest of the news
                ForEach(basketballNews.dropFirst(), id: \.title) { newsItem in
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
//                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Divider()
                            .padding(.horizontal, 10)
                            .background(Color.gray)
                    }
                }
            }
            .padding(.horizontal) // Add padding around the entire content
        }
    }
    private var lotteryContent: some View {
        ScrollView {
            VStack {
                let lotteryNews = newsList.filter { $0.type == .lottery }
                
                if let latestNews = lotteryNews.first {
                    VStack {
                        Image(latestNews.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 200)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.bottom, 10)
                        
                        Text(latestNews.title)
                            .font(.title3)
                            .fontWeight(.bold)
//                            .multilineTextAlignment(.leading)
                    }
                    Divider().padding(.horizontal, 10).background(Color.gray)
                }
                
                // The rest of the news
                ForEach(lotteryNews.dropFirst(), id: \.title) { newsItem in
                    VStack{
                        HStack {
                            Image(newsItem.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 70)
                                .cornerRadius(10)
                                .clipped()
                                .padding(.trailing, 10)
                            
                            Text(newsItem.title)
                                .font(.caption)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Divider().padding(.horizontal, 10).background(Color.gray)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    private var showContents: some View {
        ScrollView {
            VStack {
                
            }
        }
    }
}

#Preview {
    ContentView()
}

struct NewsModel {
    let image: String
    let title: String
    let type: NewsType
}

enum NewsType: Int {
    case football = 1
    case basketball = 2
    case lottery = 3
}
