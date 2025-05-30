//
//  CharactersViewModel.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation
import Alamofire

class CharactersViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var searchQuery: String = ""
    @Published var selectedStatus: String = ""
    @Published var selectedGender: String = ""

    private var currentPage = 1
    private var totalPages = Int.max

    func resetAndFetch() {
        currentPage = 1
        totalPages = Int.max
        characters = []
        fetchCharacters()
    }

    func fetchCharactersIfNeeded(currentCharacter: Character?) {
        guard let current = currentCharacter else {
            fetchCharacters()
            return
        }

        let thresholdIndex = characters.index(characters.endIndex, offsetBy: -1) // last item
        if characters.firstIndex(where: { $0.id == current.id }) == thresholdIndex {
            print("Triggering API fetch for page \(currentPage)")
            fetchCharacters()
        }
    }

    private func buildQueryURL() -> String {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
        var queryItems = [URLQueryItem(name: "page", value: "\(currentPage)")]

        if !searchQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: searchQuery))
        }
        if !selectedStatus.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: selectedStatus))
        }
        if !selectedGender.isEmpty {
            queryItems.append(URLQueryItem(name: "gender", value: selectedGender))
        }

        components.queryItems = queryItems
        return components.string!
    }

    private func fetchCharacters() {
        guard !isLoading, currentPage <= totalPages else { return }

        isLoading = true
        let url = buildQueryURL()

        AF.request(url)
            .validate()
            .responseDecodable(of: CharactersResponse.self) { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false

                switch response.result {
                case .success(let data):
                    self.characters.append(contentsOf: data.results)
                    self.totalPages = data.info.pages
                    self.currentPage += 1
                case .failure(let error):
                    print("Error fetching characters: \(error)")
                }
            }
    }
}
