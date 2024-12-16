//
//  JournalDetailViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI
import Combine

class JournalDetailViewModel: ObservableObject {
    @Published var JD: [JournalDetailModel] = []
    
    func fetchJournalDetail(albumID: Int, issueYear: String) {
//        let url = URL(string: "https://gateway.luckyinfos.com/api/journal/journals/2024/107?lang=en")!
        let url = URL(string:"https://gateway.luckyinfos.com/api/journal/journals/\(issueYear)/\(albumID)?lang=en")!

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
                let decodedResponse = try JSONDecoder().decode(JournalDetailResponseModel.self, from: data)
                
                if let jd = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.JD = jd
                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON: ", jsonError)
            }
        }
        task.resume()
    }
}
