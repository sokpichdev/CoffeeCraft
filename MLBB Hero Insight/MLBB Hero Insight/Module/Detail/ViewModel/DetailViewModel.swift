//
//  DetailViewModel.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//

import SwiftUI

@MainActor
class DetailViewModel: ObservableObject {
    @Published var detail: [HeroDetailRecord] = []
    @Published var isLoading: Bool = false
    @Published var isFetched: Bool = false
    @Published var errorMessage: String?
    
    func loadDetail(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://mlbb-stats.ridwaanhall.com/api/hero-detail/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoded = try JSONDecoder().decode(HeroResponse.self, from: data)
            self.detail = decoded.data.records
        } catch is CancellationError {
            print("🟡 Load cancelled.")
        } catch {
            print("🔴 Load error: \(error.localizedDescription)")
            errorMessage = "Failed to load hero details. Please try again."
        }
        
        isFetched = true
        isLoading = false
    }
}
