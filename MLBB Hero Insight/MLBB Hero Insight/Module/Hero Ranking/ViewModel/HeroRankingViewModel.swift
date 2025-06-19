//
//  HeroRankingViewModel.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import Foundation

class HeroRankingViewModel: ObservableObject {
    @Published var rankings: [HeroRankingRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    @Published var selectedDay: Int = 7
    @Published var selectedRank: String = "mythic"
    @Published var size: String = "10"
    @Published var index: String = "0"
    @Published var sortField: String = "win_rate"
    @Published var sortOrder: String = "desc"


    func loadRankings() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let url = URL(string: "https://mlbb-stats.ridwaanhall.com/api/hero-rank/")!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(HeroRankingResponse.self, from: data)

            if response.code == 0 {
                await MainActor.run {
                    self.rankings = response.data.records
                    self.isLoading = false
                }
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            await MainActor.run {
                print("🔴 Error: \(error.localizedDescription)")
                self.errorMessage = "Failed to load rankings."
                self.isLoading = false
            }
        }
    }
}
