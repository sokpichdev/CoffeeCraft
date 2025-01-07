//
//  Model.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import Foundation

struct Users : Decodable{
    let page : Int
    let perPage : Int
    let total: Int
    let totalPages : Int
    let data : [User]
}

struct User : Decodable, Hashable{
    let id : Int
    let email : String
    let firstName : String
    let lastName : String
    let avatar : URL
}
