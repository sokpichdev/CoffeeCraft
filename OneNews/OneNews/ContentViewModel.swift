//
//  ContentViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/3/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published public var selectedCategoryIndex: Int = 0
    @Published public var newsImage: String = ""
    @Published public var selectedNews: NewsModel? = nil
    
    let categories = ["All", "Football", "Basketball", "Lottery"]
    
    @Published var news: [NewsModel] = [
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
