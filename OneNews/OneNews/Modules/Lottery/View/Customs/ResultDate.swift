//
//  ResultDate.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultDate: View {
//    @ObservedObject var lotteryVM: LotteryViewModel
    var drawID: Int
    var date: String
    var issue: String
    var officialIssue: String
    var body: some View {
        Text("DRAW ID - \(issue + officialIssue)")
            .font(.caption)
            .foregroundColor(Color.letters.opacity(0.5))
        
        HStack {
            Text(date.formatDetailDate(from: date, type: .day) ?? "").fontWeight(.bold)
            Text(" | ")
            Text(date.formatDetailDate(from: date, type: .longDateTime) ?? "")
        }
        .font(.caption)
        .frame(height: 12)
    }
}
