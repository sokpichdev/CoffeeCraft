//
//  UsersViewModel.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//
import SwiftUI
import Alamofire

class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var isFirstLoading = true
    var totalPages = 0
    var page = 1

    //MARK: - PAGINATION
    func loadMoreContent(currentItem item: User) {
        // Check if we are at the last item and haven't loaded the last page yet
        if let lastItem = users.last, lastItem.id == item.id, (page + 1) <= totalPages, !isLoading {
            page += 1
            getUsers()
        }
    }

    //MARK: - API CALL
    func getUsers() {
        guard !isLoading else { return }

        print("Hit API for page: \(page)")
        isLoading = true

        let apiUrl = "https://rickandmortyapi.com/api/character/?page=\(page)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        AF.request(apiUrl).validate().responseDecodable(of: Users.self, decoder: decoder) { [weak self] (response) in
            guard let self = self else { return }

            DispatchQueue.main.async { // always update published properties on main thread
                self.isLoading = false
                self.isFirstLoading = false

                switch response.result {
                case .success(let usersResponse):
                    self.totalPages = usersResponse.info.pages
                    self.users.append(contentsOf: usersResponse.results)
                case .failure(let error):
                    print("Error decoding users: \(error.localizedDescription)")
                }
            }
        }
    }
}

