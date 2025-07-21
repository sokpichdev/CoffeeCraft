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
    @Published var allHeroes: [Hero] = [] // For relationship hero references
    @Published var isLoading: Bool = false
    @Published var isFetched: Bool = false
    @Published var errorMessage: String?
    
    func loadDetail(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://mlbb-stats.ridwaanhall.com/api/hero-detail/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)

            do {
                let decoded = try JSONDecoder().decode(HeroResponse.self, from: data)
                self.detail = decoded.data?.records ?? []
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Missing key: \(key.stringValue) in \(context)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("❌ Type mismatch for type \(type) in \(context)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("❌ Value \(value) not found in \(context)")
            } catch let DecodingError.dataCorrupted(context) {
                print("❌ Data corrupted: \(context)")
            } catch {
                print("❌ Other error: \(error.localizedDescription)")
            }
            
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
