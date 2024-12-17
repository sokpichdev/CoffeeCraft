//
//  IssueListViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//


import SwiftUI
import Combine

class IssueListViewModel: ObservableObject {
    @Published var issueList: [IssueListModel] = []
    
    func fetchIssueList(albumID: Int, issueYear: String) {
        let url = URL(string: "https://gateway.luckyinfos.com/api/journal/journals/year/\(albumID)?lang=en")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error while fetching data: ", error)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(BaseModel<[IssueListModel]>.self, from: data)
                
                if let issueList = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.issueList = issueList
                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON: ", jsonError)
            }
        }
        task.resume()
    }
}
