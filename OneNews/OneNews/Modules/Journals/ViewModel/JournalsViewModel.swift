//
//  JournalsViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//
import Foundation
import Combine

class JournalsViewModel: ObservableObject {
    @Published var journals: [AlbumModel] = []
    
    func fetchJournals() {
        let url = URL(string: "https://gateway.luckyinfos.com/api/journal/journals?lang=en&page=1")!
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
                let decodedResponse = try JSONDecoder().decode(JournalResponseModel.self, from: data)
                
                // Check if 'data' exists and assign to the journals array
                if let journals = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.journals = journals
                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON:", jsonError)
            }
        }
        
        task.resume()
    }
}
