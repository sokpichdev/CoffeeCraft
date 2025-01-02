//
//  MatchesViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/19/24.
//

import SwiftUI

class MatchesViewModel:  ObservableObject{
    @Published var matches: [LeagueModel] = []
    func fetchMatches(sportID: Int, date: String, matchType: MatchType) {
        matches.removeAll()
        print("Fetching matches for Sport ID: \(sportID), Date: \(date), Match Type: \(matchType)")
        
        let FixturesResultsUrl = URL(string: "https://gateway.luckyinfos.com/api/sport/sports/\(sportID)/\(matchType)?lang=en&match_date=\(date)&timezone=Asia/Phnom_Penh&page=1&sport=\(sportID)")!
        
        let liveUrl = URL(string: "https://gateway.luckyinfos.com/api/sport/sports/1/live?lang=en&page=1")!
        
        var url: URL
        
        if matchType == .live {
            url = liveUrl
        } else {
            url = FixturesResultsUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.matches = []
                    print("Error while fetching data: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MatchesResponseModel.self, from: data)
                
                if let matches = decodedResponse.data, !matches.isEmpty {
                    DispatchQueue.main.async {
                        self?.matches = matches
                        print("Decoded Matches:")
                        matches.forEach { match in
                            print(match.debugDescription)
                            if let sport = match.sport {
                                print(sport.debugDescription)
                            }
                            if let detail = match.matches {
                                print(detail.debugDescription)
                            }
                        }
                    }
                } else {
                    print("No matches available.")
                }
            } catch let jsonError {
                print("Failed to decode JSON: \(jsonError)")
                print("Raw JSON Response:", String(data: data, encoding: .utf8) ?? "Invalid JSON")
            }
        }
        
        task.resume()
    }
    
    
}
