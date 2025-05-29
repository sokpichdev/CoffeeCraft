//
//  FavoritesManager.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteCharacters: [Character] = []
    @Published private(set) var favoriteEpisodes: [Episode] = []
    @Published private(set) var favoriteLocations: [Location] = []

    private let charKey = "FavoriteCharacters"
    private let epKey = "FavoriteEpisodes"
    private let locKey = "FavoriteLocations"

    private init() {
        loadAll()
    }

    // MARK: - Character
    func toggleFavorite(_ character: Character) {
        if isFavorite(character) {
            favoriteCharacters.removeAll { $0.id == character.id }
        } else {
            favoriteCharacters.append(character)
        }
        save(charKey, favoriteCharacters)
    }

    func isFavorite(_ character: Character) -> Bool {
        favoriteCharacters.contains { $0.id == character.id }
    }

    // MARK: - Episode
    func toggleFavorite(_ episode: Episode) {
        if isFavorite(episode) {
            favoriteEpisodes.removeAll { $0.id == episode.id }
        } else {
            favoriteEpisodes.append(episode)
        }
        save(epKey, favoriteEpisodes)
    }

    func isFavorite(_ episode: Episode) -> Bool {
        favoriteEpisodes.contains { $0.id == episode.id }
    }

    // MARK: - Location
    func toggleFavorite(_ location: Location) {
        if isFavorite(location) {
            favoriteLocations.removeAll { $0.id == location.id }
        } else {
            favoriteLocations.append(location)
        }
        save(locKey, favoriteLocations)
    }

    func isFavorite(_ location: Location) -> Bool {
        favoriteLocations.contains { $0.id == location.id }
    }

    // MARK: - Persistence
    private func save<T: Codable>(_ key: String, _ data: [T]) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func loadAll() {
        if let data = UserDefaults.standard.data(forKey: charKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            favoriteCharacters = decoded
        }
        if let data = UserDefaults.standard.data(forKey: epKey),
           let decoded = try? JSONDecoder().decode([Episode].self, from: data) {
            favoriteEpisodes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: locKey),
           let decoded = try? JSONDecoder().decode([Location].self, from: data) {
            favoriteLocations = decoded
        }
    }
}

