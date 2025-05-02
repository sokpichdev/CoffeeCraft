//
//  Model.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import Foundation

struct Users: Decodable {
    let info: Info
    let results: [User]
}

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct User: Decodable, Hashable {
    let id: Int
    let name: String
    let image: String
}
