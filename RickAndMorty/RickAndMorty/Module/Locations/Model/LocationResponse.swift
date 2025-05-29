//
//  LocationResponse.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation

struct LocationResponse: Decodable {
    let info: Info
    let results: [Location]
}

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
