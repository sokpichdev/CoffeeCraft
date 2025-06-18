//
//  HomeViewModel.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var heroes: [Hero] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadHeroes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://mlbb-stats.ridwaanhall.com/api/hero-list/")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let rawResponse = try JSONDecoder().decode([String: String].self, from: data)
            let mappedHeroes = rawResponse.map { Hero(id: $0.key, name: $0.value) }
                .sorted {
                    (Int($0.id) ?? 0) > (Int($1.id) ?? 0)
                }
            
            heroes = mappedHeroes
            isLoading = false
        } catch is CancellationError {
            print("🟡 Load cancelled.")
        } catch {
            print("🔴 Load error: \(error.localizedDescription)")
            errorMessage = "Failed to load heroes. Please try again."
            isLoading = false
        }
    }
}
