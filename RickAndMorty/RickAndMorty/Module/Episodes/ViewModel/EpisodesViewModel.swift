//
//  EpisodesViewModel.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import SwiftUI
import Alamofire

class EpisodesViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var page = 1
    @Published var totalPages = 1

    func resetAndFetch() {
        episodes = []
        page = 1
        fetchEpisodes()
    }

    func fetchEpisodes() {
        guard !isLoading, page <= totalPages else { return }

        isLoading = true
        let baseUrl = "https://rickandmortyapi.com/api/episode"
        let searchPart = searchQuery.isEmpty ? "" : "?name=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let pagePart = searchQuery.isEmpty ? "?page=\(page)" : "&page=\(page)"
        let url = baseUrl + searchPart + pagePart

        AF.request(url)
            .validate()
            .responseDecodable(of: EpisodeResponse.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    self.totalPages = data.info.pages
                    self.episodes.append(contentsOf: data.results)
                    self.page += 1
                case .failure(let error):
                    print("Failed to fetch episodes: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
    }

    func fetchIfNeeded(currentItem: Episode) {
        if episodes.last == currentItem {
            fetchEpisodes()
        }
    }
    
    func fetchEpisodesIfNeeded(currentEpisode: Episode?) {
        guard let current = currentEpisode else {
            fetchEpisodes()
            return
        }
        
        let thresholdIndex = episodes.index(episodes.endIndex, offsetBy: -1)
        if episodes.firstIndex(where: { $0.id == current.id }) == thresholdIndex {
            print("Triggering API fetch for page \(page)")
            fetchEpisodes()
        }
    }
}
