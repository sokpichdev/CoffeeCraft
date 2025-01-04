//
//  ResultView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct ResultView: View {
//    @State var lists: [Int] = [] // Changed to 1D array
//    @ObservedObject var lotteryVM: LotteryViewModel
    var drawID: Int
    var result: String
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult(iconName: iconName, title: title)
            
            ResultDetail(lists: result.convertStringToListOfStrings(result),
                         drawID: drawID,
                         date: openDate,
                         issue: issue,
                         officialIssue: officialIssue,
                         isSpecial: false)
//            ResultDetail(lotteryVM: lotteryVM)
            
            Spacer()
            MoreResultButton()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
        
    }
}

