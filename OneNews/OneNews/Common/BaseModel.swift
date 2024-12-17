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
    var data: T?
    
    struct Message: Codable {
        var title: String?
        var description: String?
    }
}
