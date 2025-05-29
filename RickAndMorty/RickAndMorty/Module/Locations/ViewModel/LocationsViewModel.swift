//
//  LocationsViewModel.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation
import Alamofire

class LocationsViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var page = 1
    @Published var totalPages = 1

    func resetAndFetch() {
        locations = []
        page = 1
        fetchLocations()
    }

    func fetchLocations() {
        guard !isLoading, page <= totalPages else { return }

        isLoading = true
        let baseUrl = "https://rickandmortyapi.com/api/location"
        let searchPart = searchQuery.isEmpty ? "" : "?name=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let pagePart = searchQuery.isEmpty ? "?page=\(page)" : "&page=\(page)"
        let apiUrl = baseUrl + searchPart + pagePart

        AF.request(apiUrl)
            .validate()
            .responseDecodable(of: LocationResponse.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let locationResponse):
                    self.totalPages = locationResponse.info.pages
                    self.locations.append(contentsOf: locationResponse.results)
                    self.page += 1
                case .failure(let error):
                    print("Failed to fetch locations: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
    }

    func fetchIfNeeded(currentItem: Location) {
        if locations.last == currentItem {
            fetchLocations()
        }
    }
}
