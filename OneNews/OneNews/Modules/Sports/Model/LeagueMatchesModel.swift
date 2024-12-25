//
//  LeagueMatchesModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/24/24.
//
import SwiftUI

struct LeagueMatchesResponse: Codable {
    var status: Bool?
    var message: Message?
    var data: DataContainer?
    
    struct Message: Codable {
        var title: String?
        var description: String?
    }
    
    struct DataContainer: Codable {
        var matches: LeagueMatchesModel?
        var league: League?
        
        struct League: Codable {
            var id: Int?
            var icon: String?
            var isCup: Int?
            var name: String?
            var country: String?
            var favorite: Bool?
            
            private enum CodingKeys: String, CodingKey {
                case isCup = "is_cup"
            }
        }
    }
}

struct LeagueMatchesModel: Codable {
    var currentPage: Int?
    var data: [MatchDetailModel]?
    var firstPageURL: String?
    var from: Int?
    var lastPage: Int?
    var lastPageURL: String?
    var links: [Links]?
    var nextPageURL: String?
    var path: String?
    var perPage: Int?
    var prevPageURL: String?
    var to: Int?
    var total: Int?
    
    private enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
    }
}

struct Links: Codable {
    var url: String?
    var label: String?
    var active: Bool?
}

