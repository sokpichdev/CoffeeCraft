//
//  LotteryViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 1/2/25.
//
import SwiftUI
import Combine

class LotteryViewModel: ObservableObject {
    @Published var lotteryVM: [LotteryModel] = []
    private var currentPage = 1
    private var isFetching = true
    private var hasMorePages = true
    
    func fetchLottery(countryID: Int, pageNo: Int) {
//        isFetching = true
        
        
        let url = URL(string: "http://89.116.21.222:8000/api/lottery/lotteries/country/\(countryID)?page=\(pageNo)&lang=en")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isFetching = false }
            
            if let error = error {
                print("Error while fetching data: ", error)
                return
            }
            
            guard let data = data else {
                print("No Data received.")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(BaseModel<[LotteryModel]>.self, from: data)
                
                if let lottery = decodedResponse.data, !lottery.isEmpty {
                    DispatchQueue.main.async {
                        if pageNo == 1 {
                            self?.lotteryVM = lottery
                        } else {
                            self?.lotteryVM.append(contentsOf: lottery)
                        }
                        self?.currentPage = pageNo
                        self?.hasMorePages = decodedResponse.meta?.currentPage ?? 1 < (decodedResponse.meta?.lastPage ?? 1)
                        print("Lottery Count: \(self?.lotteryVM.count ?? 0)")
                    }
                } else {
                    self?.hasMorePages = false
                }
            } catch {
                print("Failed to decode JSON: ", error)
            }
        }
        task.resume()
    }
    
    func loadMore(countryID: Int) {
        fetchLottery(countryID: countryID, pageNo: currentPage + 1)
    }
}
