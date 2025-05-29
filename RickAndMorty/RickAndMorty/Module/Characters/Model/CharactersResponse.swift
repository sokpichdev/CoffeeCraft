//
//  CharactersResponse.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation

struct CharactersResponse: Codable {
    let info: Info
    let results: [Character]
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct Character: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: String
    let origin: Origin
    let location: Origin
}

struct Origin: Codable, Hashable {
    let name: String
    let url: String
}
