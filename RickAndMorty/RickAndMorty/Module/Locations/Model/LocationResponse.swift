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

struct Location: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
}
