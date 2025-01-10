//
//  LotteryResultViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 1/10/25.
//

import SwiftUI
import Combine

class LotteryResultViewModel: ObservableObject {
    @Published var lRVM: [LotteryResultModel] = []
    
    func fetchLotteryList(lotteryListID: Int, date: String) {
        let url = URL(string: "http://89.116.21.222:8000/api/lottery/lotteries/\(lotteryListID)?date=\(date)&lang=en")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error while fetching data: ", error)
                return
            }
            
            guard let data = data else {
                print("No Data Received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(BaseModel<[LotteryResultModel]>.self, from: data)
                
                if let lotteryList = decodedResponse.unifiedData {
                    DispatchQueue.main.async {
                        self?.lRVM = lotteryList
                        print("Lottery List Count: \(lotteryList.count)")
                    }
                } else {
                    print("No lottery data available.")
                }
            } catch {
                print("Failed to decode JSON: ", error)
            }
        }
        task.resume()
    }

}
