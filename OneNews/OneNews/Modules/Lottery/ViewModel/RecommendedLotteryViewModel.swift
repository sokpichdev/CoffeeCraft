//
//  RecommendedLotteryViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 1/3/25.
//

import SwiftUI
import Combine

class RecommendedLotteryViewModel: ObservableObject {
    @Published var rLVM: [LotteryModel] = []

    func fetchLottery() {
        rLVM.removeAll()
        
        let url = URL(string: "http://89.116.21.222:8000/api/lottery/lotteries/recommended/3?lang=en")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error while fetching data: ", error)
                return
            }
            
            guard let data = data else {
                print("No Data received.")
                return
            }
            
            do {
                // Pretty-print the JSON response
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON Response:\n", jsonString)
                }
                
                // Decode the data into the model
                let decodedResponse = try JSONDecoder().decode(BaseModel<[LotteryModel]>.self, from: data)
                
                if let lottery = decodedResponse.data {
                    DispatchQueue.main.async {
                        self?.rLVM = lottery
                        print("Lottery Count: \(lottery.count)")
                    }
                }
            } catch let jsonError {
                print("Failed to decode JSON: ", jsonError)
            }
        }
        task.resume()
    }

}
