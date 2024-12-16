//
//  JournalDetailModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//



import SwiftUI

struct JournalDetailResponseModel: Codable {
    var data: [JournalDetailModel]?
    var status: Bool?
    var message: MessageModel?
    
    struct MessageModel: Codable {
        var tittle: String?
        var description: String?
    }
}

struct JournalDetailModel: Codable {
    var albumID: Int?
    var issueYear: String?
    var issueNo: String?
    var attachments: String?
    
    private enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case issueYear = "issue_year"
        case issueNo = "issue_no"
        case attachments
    }
    
}
