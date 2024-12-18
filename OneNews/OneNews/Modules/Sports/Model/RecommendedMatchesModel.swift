//
//  RecommendedMatchesModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//
import SwiftUI

struct RecommendedMatchesModel: Codable, Identifiable {
    var id: Int?
    var league: League?
    var leagueID: Int?
    var date: String?
    var status: String? // Finished,
    var time: String?
    var timer: String?
    var isLive: Bool?
    var homeTeamScore: String?
    var awayTeamScore: String?
    var scheduledTime: String?
    var formattedDateTime: String?
    var displayDateTime: String?
    var homeTeam: Team?
    var awayTeam: Team?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case league
        case leagueID = "league_id"
        case date
        case status
        case time
        case timer
        case isLive = "is_live"
        case homeTeamScore = "home_team_score"
        case awayTeamScore = "away_team_score"
        case scheduledTime = "scheduled_time"
        case formattedDateTime = "formatted_date_time"
        case displayDateTime = "display_date_time"
        case homeTeam = "hometeam"
        case awayTeam = "awayteam"
    }
}

struct League: Codable, Identifiable {
    var id: Int?
    var icon: String?
    var isCup: Int?
    var name: String?
    var country: String?
    var favorite: Bool?
    var sport: Sport?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case icon
        case isCup = "is_cup"
        case name
        case country
        case favorite
        case sport
    }
}

struct Sport: Codable, Identifiable {
    var id: Int?
    var name: String?
    var icon: String?
    var activeIcon: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case activeIcon = "active_icon"
    }
}

struct Team: Codable {
    var name: String?
    var logo: String?
    var logoPath: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case logo
        case logoPath = "logo_path"
    }
}
