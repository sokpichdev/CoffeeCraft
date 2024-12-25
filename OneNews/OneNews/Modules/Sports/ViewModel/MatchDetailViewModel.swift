//
//  MatchDetailViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine

class MatchDetailViewModel: ObservableObject {
    @Published var mDVM: [MatchDetailModel] = []
    
    func fetchRecomendedMatches(sportID: Int) {
        mDVM.removeAll()
        
        let url = URL(string: "https://gateway.luckyinfos.com/api/sport/sports/1/leagues/141/matches/111948?lang=en")!
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
                let decodedResponse = try JSONDecoder().decode(BaseModel<MatchDetailModel>.self, from: data)
                
                
                if let matchDetail = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.mDVM = [matchDetail]
                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON:", jsonError)
            }
        }
        
        task.resume()
    }
}
