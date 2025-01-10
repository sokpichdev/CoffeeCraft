//
//  ResultDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultDetail : View {
    var result: [String] = [""]
    
//    var lotCatID: Int
//    var lotListID: Int
    var date: String
    var issue: String = ""
    var officialIssue: String = ""
    var dn : String = ""
    var isSpecial: Bool = true
    
    var body: some View {
        VStack {
            let text = dn == "" ? issue + officialIssue : dn
            Text("DRAW ID - \(text)")
                .font(.caption)
                .foregroundColor(Color.letters.opacity(0.5))
            
            HStack {
                Text(date.formatDetailDate(type: .day) ?? "").fontWeight(.bold)
                Text(" | ")
                Text(date.formatDetailDate(type: .longDateTime) ?? "")
            }
            .font(.caption)
            .frame(height: 12)
            
            if isSpecial {
                Text("Special Prize").foregroundStyle(.main).fontWeight(.semibold)
            } else {
                Text("")
            }
            
            // Circles in rows
//            let finalResult = resultType == nil ? result : resultType
            LotteryResultView(result: result, styleResult: .normal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(Color.optionBtn2)
    }
}


