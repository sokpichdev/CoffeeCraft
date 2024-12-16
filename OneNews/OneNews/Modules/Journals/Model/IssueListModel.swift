//
//  IssueListModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct IssueListResponseModel: Codable {
    var status: Bool?
    var message: [Message]?
    var data: [IssueListData]?
    
    struct Message: Codable {
        var title: String?
        var description: String?
    }
}

struct IssueListData: Codable {
    var issueYear: String?
    var issueList: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case issueYear = "issue_year"
        case issueList = "issue_list"
    }
}
