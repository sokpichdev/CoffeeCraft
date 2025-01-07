//
//  ResultView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct ResultView: View {
    var drawID: Int
    var result: CodeType?
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult(iconName: iconName, title: title)
            
            if case let .string(lottery) = result {
                ResultDetail(result: lottery,
                             drawID: drawID,
                             date: openDate,
                             issue: issue,
                             officialIssue: officialIssue,
                             isSpecial: false)
            }
//            ResultDetail(lists: result.convertStringToListOfStrings(result),
//                         drawID: drawID,
//                         date: openDate,
//                         issue: issue,
//                         officialIssue: officialIssue,
//                         isSpecial: false)
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

