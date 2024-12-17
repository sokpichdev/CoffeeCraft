//
//  RecommendedModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct RecommendedResponseModel: Codable {
    var status: Bool?
    var message: Message?
    var data: [RecommendedModel]?
    
    struct Message: Codable {
        var title: String?
        var description: String?
    }
}

struct RecommendedModel: Codable{
    var id: Int?
    var albumID: Int?
    var issueYear: String?
    var issueNo: String?
    var attachments: String?
    var album: AlbumModel?
    
    struct AlbumModel: Codable, Identifiable {
        var id: Int?
        var name: String?
    }
    
    private enum CodingKeys: String, CodingKey {
            case id
            case albumID = "album_id"
            case issueYear = "issue_year"
            case issueNo = "issue_no"
            case attachments 
            case album
        }
}
