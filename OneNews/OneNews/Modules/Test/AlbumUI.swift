//
//  AlbumUI.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct AlbumUI: View {
    @StateObject private var viewModel = LotteryViewModel()

    var body: some View {
        VStack {
            Button("Fetch Lottery Data") {
                viewModel.fetchLottery()
            }
            List(viewModel.lotteryVM) { lottery in
                VStack(alignment: .leading) {
                    Text(lottery.title ?? "No Title")
                    Text("ID: \(lottery.id ?? 0)")
                    Text("detail; \(lottery.result?.detail?.code ?? "")")
                }
            }
        }
        
    }
}

#Preview {
    AlbumUI()
}
