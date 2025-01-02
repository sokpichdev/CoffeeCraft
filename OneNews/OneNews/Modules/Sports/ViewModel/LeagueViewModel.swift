//
//  LeagueViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/24/24.
//

import SwiftUI
import Combine

class LeagueViewModel: ObservableObject {
    @Published var matchList: [MatchDetailModel] = []
    
    func fetchLeagueMatches(sportID: Int, leagueID: Int, matchType: MatchType) {
        matchList.removeAll()
        
        let urlString = "http://89.116.21.222:8000/api/sport/sports/\(sportID)/leagues/\(leagueID)/\(matchType)?lang=en&page=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(LeagueMatchesResponse.self, from: data)
                if let matches = decodedResponse.data?.matches {
                    if let match = matches.data {
                        DispatchQueue.main.async {
                            self?.matchList = match
                        }
                    }
                    print("Matches Current Page: \(matches.currentPage ?? 0)")
                    print("First Match Home Team: \(matches.data?.first?.homeTeam?.name ?? "N/A")")
                }

                if let league = decodedResponse.data?.league {
                    print("League Name: \(league.name ?? "Unknown")")
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
