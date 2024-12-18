//
//  UpcomingMatchesModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/18/24.
//

import SwiftUI

struct UpcomingMatchesResponseModel: Codable {
    var data: [UpcomingMatchesModel]?
    var links: LinksModel?
    var meta: MetaModel?
    var status: Bool?
    var message: Message?
    
    struct Message: Codable {
        var title: String?
        var description: String?
    }
}

struct UpcomingMatchesModel: Codable, Identifiable{
    var id: Int?
    var icon: String?
    var isCup: Int?
    var name: String?
    var country: String?
    var matches: MatchesModel?
    var favorite: Bool?
    var sport: Sport?
    
    struct MatchesModel: Codable, Identifiable {
        var id: Int?
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
    
    private enum CodingKeys: String, CodingKey {
        case id
        case icon
        case isCup = "is_cup"
        case name
        case country
        case matches
        case favorite
        case sport
    }
}

struct LinksModel: Codable {
    var first: String?
    var last: String?
    var prev: String?
    var next: String?
}

struct MetaModel: Codable {
    var currentPage: Int?
    var from: Int?
    var lastPage: Int?
    var links: [LinksModel]
    var path: String?
    var perPage: Int?
    var to: Int?
    var total: Int?
    
    struct LinksModel: Codable {
        var url: String?
        var lable: String?
        var active: Bool?
    }
    
    private enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case links
        case path
        case perPage = "per_page"
        case to
        case total
    }
}
