//
//  APIService.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import Foundation

class APIService {
    static let shared = APIService()

    func fetchHeroList() async throws -> [Hero] {
        let url = URL(string: "https://mlbb-stats.ridwaanhall.com/api/hero-list/")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode([String: String].self, from: data)
        let heroes = decoded.map { Hero(id: $0.key, name: $0.value) }
        return heroes
    }
}
