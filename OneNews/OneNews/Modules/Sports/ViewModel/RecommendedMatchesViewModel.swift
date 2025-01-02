//
//  RecommendedMatchesViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/17/24.
//


import SwiftUI
import Combine

class RecommendedMatchesViewModel: ObservableObject {
    @Published var recommended: [RecommendedMatchesModel] = []
    
    func fetchRecomendedMatches(sportID: Int) {
        recommended.removeAll()
        
        let url = URL(string: "https://gateway.luckyinfos.com/api/sport/recommended-matches?lang=en&sport_id=\(sportID)&timezone=Asia/Phnom_Penh")!
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
                // Decode the response into JournalResponseModel
                let decodedResponse = try JSONDecoder().decode(BaseModel<[RecommendedMatchesModel]>.self, from: data)
                
                // Check if 'data' exists and assign to the journals array
                if let recommended = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.recommended = recommended
                        print(recommended.count)

                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON:", jsonError)
            }
        }
        
        task.resume()
    }
}
