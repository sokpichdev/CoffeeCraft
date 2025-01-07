//
//  LotteryResultView.swift
//  OneNews
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct LotteryResultView: View {
    var result: String
    var styleResult: StyleCircleResult
    var body: some View {
        // Circles in rows
        VStack {
            let lists = result.convertStringToListOfStrings()
            if lists.count >= 20 {
                HStack(spacing: -5) {
                    ForEach(lists.prefix(10), id: \.self) { number in
                        if styleResult == .recommended {
                            CircleView(number: number)
                        } else {
                            CircleResult(number: number)
                        }
                    }
                }
                HStack(spacing: -5) {
                    ForEach(lists.suffix(10), id: \.self) { number in
                        if styleResult == .recommended {
                            CircleView(number: number)
                        } else {
                            CircleResult(number: number)
                        }
                    }
                }
            } else {
                HStack(spacing: -5) {
                    ForEach(lists, id: \.self) { number in
                        if styleResult == .recommended {
                            CircleView(number: number)
                        } else {
                            CircleResult(number: number)
                        }
                    }
                }
            }
        }
    }
}

enum StyleCircleResult{
    case recommended
    case normal
}
