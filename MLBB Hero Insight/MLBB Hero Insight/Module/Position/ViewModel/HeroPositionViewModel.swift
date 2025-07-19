//
//  HeroPositionViewModel.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/20/25.
//
import SwiftUI

class HeroPositionViewModel: ObservableObject {
    @Published var positions: [HeroPositionRecord]? = []
    @Published var isLoading = false
    @Published var isFetched: Bool = false
    @Published var errorMessage: String?
    @Published var isAlreadyReset: Bool = false
    @Published var isBeingFiltered: Bool = false
    @Published var totalHeroSize: Int = 0 {
        didSet {
            if !isBeingFiltered {
                size = "\(totalHeroSize)"
            }
        }
    }
    
    // for filter
    @Published var role: String = "all"
    @Published var lane: String = "all"
    @Published var size: String = "0"
    @Published var index: String = "0"
    
    init() {
        size = "\(totalHeroSize)" // safe to ref
    }
    
    func loadPosition() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        var components = URLComponents(string: "https://mlbb-stats.ridwaanhall.com/api/hero-position/")!
        components.queryItems = [
            URLQueryItem(name: "role", value: "\(role)"),
            URLQueryItem(name: "lane", value: "\(lane)"),
            URLQueryItem(name: "size", value: "\(size)"),
            URLQueryItem(name: "index", value: "\(index)")
        ]
        guard let url = components.url else {
            await MainActor.run {
                errorMessage = "Invalid filter parameters."
                isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(HeroPositionReponse.self, from: data)
            
            if response.code == 0 {
                await MainActor.run {
                    if let positions = response.data?.records {
                        self.positions = positions
                    }
                    
                    if let totalHeroSize = response.data?.total {
                        self.totalHeroSize = totalHeroSize
                    }
                    self.isFetched = true
                    self.isLoading = false
                }
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            await MainActor.run {
                print("🔴 Error: \(error.localizedDescription)")
                self.errorMessage = "Failed to load Position."
                self.isFetched = true
                self.isLoading = false
            }
        }
    }
    func resetFilter() {
        lane = "all"
        role = "all"
        size = "\(totalHeroSize)"
        index = "0"
        if !isAlreadyReset {
            Task {
                await self.loadPosition()
            }
            self.isAlreadyReset = true
            self.isBeingFiltered = false
        }
    }
}
