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
    var data: T?       // Primary data field (array or dictionary)
    var list: T?       // Alternate data field (array or dictionary)
    
    private enum CodingKeys: String, CodingKey {
        case status, message, meta, links, data, list
    }
    
    /// Unified data source from either `data` or `list`.
    var unifiedData: T? {
        return data ?? list
    }

    /// Custom decoding to handle dynamic structure of `list` or `data`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Bool.self, forKey: .status)
        message = try container.decodeIfPresent(Message.self, forKey: .message)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
        links = try container.decodeIfPresent(Links.self, forKey: .links)
        
        if let arrayData = try? container.decode(T.self, forKey: .data) {
            data = arrayData
        } else {
            data = nil
        }
        
        if let arrayList = try? container.decode(T.self, forKey: .list) {
            list = arrayList
        } else if let objectList = try? container.decode(T.self, forKey: .list) {
            list = objectList
        } else {
            list = nil
        }
    }
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
