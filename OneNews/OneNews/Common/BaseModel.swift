//
//  BaseModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//

import SwiftUI


struct BaseModel<T: Codable>: Codable {
    var status: Bool?
    var message: Message?
    var meta: Meta?
    var links: Links?
    var data: T?
}

struct Message: Codable {
    var title: String?
    var description: String?
}

struct Meta: Codable {
    var currentPage: Int?
    var from: Int?
    var lastPage: Int?
    var links: [LinkList]?
    var path: String?
    var perPage: Int?
    var to: Int?
    var total: Int?
    
    private enum CodingKeys: String, CodingKey {
        case from, links, path, to, total
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
    }
}

struct LinkList: Codable {
    var url: String?
    var label: String?
    var active: Bool?
}
