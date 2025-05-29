//
//  EpisodeResponse.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Combine

struct EpisodeResponse: Decodable {
    let info: Info
    let results: [Episode]
}

struct Episode: Identifiable, Codable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
}

extension Episode: Equatable {
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }
}
