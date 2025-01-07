//
//  ResultDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultDetail : View {
//    @ObservedObject var lotteryVM: LotteryViewModel
    var result: String// Changed to 1D array
    var drawID: Int
    var date: String
    var issue: String
    var officialIssue: String
    var isSpecial: Bool = true
    
    var body: some View {
        VStack {
            ResultDate(drawID: drawID, date: date, issue: issue, officialIssue: officialIssue)
            
            if isSpecial {
                Text("Special Prize").foregroundStyle(.main).fontWeight(.semibold)
            } else {
                Text("")
            }
            
            // Circles in rows
            LotteryResultView(result: result, styleResult: .normal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(Color.optionBtn2)
    }
}


