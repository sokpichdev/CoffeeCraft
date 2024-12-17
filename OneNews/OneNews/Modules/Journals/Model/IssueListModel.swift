//
//  IssueListModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct IssueListModel: Codable {
    var issueYear: String?
    var issueList: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case issueYear = "issue_year"
        case issueList = "issue_list"
    }
}



