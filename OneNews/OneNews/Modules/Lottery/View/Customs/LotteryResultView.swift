//
//  LotteryResultView.swift
//  OneNews
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct LotteryResultView: View {
    var result: [String]
    var styleResult: StyleCircleResult
    var lotCatID: Int = 2
    var color: String = "main"
    var animal: String = ""
    var backgroundColor: Color = Color.percentage
    var foregroudColor: Color = Color.letters
    
    var body: some View {
        // Circles in rows
        VStack(spacing: 5) {
            let chunks = result.chunked(into: 10) // Split the list into rows dynamically
            if lotCatID == 3 {
                HStack(spacing: 5) {
                    ForEach(result, id: \.self) { row in
                        CircleViewForStyle(number: row, color: color, animal: animal, styleResult: styleResult, lotteryCategoryID: lotCatID, backgroundColor: backgroundColor, foregroundColor: foregroudColor)
                    }
                }
                
            } else if lotCatID == 5 {
                ForEach(chunks, id: \.self) { row in
                    HStack(spacing: 15) {
                        ForEach(row, id: \.self) { number in
                            CircleViewForStyle(number: number, color: "white", styleResult: styleResult, lotteryCategoryID: lotCatID, backgroundColor: backgroundColor, foregroundColor: foregroudColor)
                        }
                    }
                }
            } else {
                ForEach(chunks, id: \.self) { row in
                    HStack(spacing: -5) {
                        ForEach(row, id: \.self) { number in
                            CircleViewForStyle(number: number, styleResult: styleResult, lotteryCategoryID: lotCatID, backgroundColor: backgroundColor, foregroundColor: foregroudColor)
                        }
                    }
                }
            }
        }
    }
}

struct CircleViewForStyle: View {
    var number: String
    var color: String = "main"
    var animal: String = ""
    var styleResult: StyleCircleResult
    var lotteryCategoryID: Int
    var backgroundColor: Color = Color.percentage
    var foregroundColor: Color
    
    var body: some View {
        if styleResult == .recommended {
            CircleView(number: number)
        } else {
            CircleResult(number: number, color: color, animal: animal, lotCatID: lotteryCategoryID, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
        }
    }
}




enum StyleCircleResult{
    case recommended
    case normal
}
