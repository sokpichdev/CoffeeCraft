//
//  JournalsModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct JournalResponseModel: Codable {
    var data: [AlbumModel]?
    var status: Bool?
    var message: MessageModel?
    
    struct MessageModel: Codable {
        var tittle: String?
        var description: String?
    }
}

struct AlbumModel: Codable, Identifiable {
    var id: Int?
    var name: String?
    var cover: String?
    var journal: JournalModel?
    var favorite: Bool?
}

struct JournalModel: Codable, Identifiable {
    var id: Int?
    var issueYear: String?
    var issueNo: String?

    private enum CodingKeys: String, CodingKey {

        // Map snake_case keys to camelCase
        case issueYear = "issue_year"
        case issueNo = "issue_no"
    }
}
