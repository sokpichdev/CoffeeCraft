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
    
    func fetchLottery() {
        lotteryVM.removeAll()
        
        let url = URL(string: "")
    }
}
