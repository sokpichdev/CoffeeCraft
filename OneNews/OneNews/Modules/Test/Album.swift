//
//  Album.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct Album: Codable, Identifiable {
    // The names of the variables should match with the keys used in the link. Also, the data types should match with the values of the URL link.
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
