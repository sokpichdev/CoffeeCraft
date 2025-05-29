//
//  LocationDetailViewModel.swift
//  RickAndMorty
//
//  Created by Sok Pich on 5/29/25.
//
import Foundation
import Alamofire

class LocationDetailViewModel: ObservableObject {
    @Published var residents: [Character] = []
    @Published var isLoading = false

    func fetchResidents(from urls: [String]) {
        guard !isLoading else { return }

        isLoading = true

        // Extract character IDs from URLs
        let ids = urls.compactMap { URL(string: $0)?.lastPathComponent }.joined(separator: ",")

        let endpoint = "https://rickandmortyapi.com/api/character/\(ids)"
        AF.request(endpoint)
            .validate()
            .responseDecodable(of: [Character].self) { [weak self] response in
                switch response.result {
                case .success(let characters):
                    self?.residents = characters
                case .failure:
                    // Handle single character case (when only one resident)
                    AF.request(endpoint)
                        .validate()
                        .responseDecodable(of: Character.self) { res in
                            if case let .success(character) = res.result {
                                self?.residents = [character]
                            }
                        }
                }
                self?.isLoading = false
            }
    }
}
