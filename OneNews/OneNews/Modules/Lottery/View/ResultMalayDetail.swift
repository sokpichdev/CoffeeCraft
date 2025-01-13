//
//  ResultMalayDetail.swift
//  OneNews
//
//  Created by Sok Pich on 1/13/25.
//

import SwiftUI

import SwiftUI

struct ResultMalayDetail: View {
    let prizeTh = ["1st PRIZE", "2nd PRIZE", "3rd PRIZE"]
    let specialResults: [Int] = Array(1...10)
    let consolationResults: [Int] = Array(11...20)
    
    let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        VStack {
            HStack {
                Text("DRAW ID - 147/25")
                Spacer()
                Text("12 January 2025 Sunday")
            }
            .font(.caption)
            .frame(height: 12)
            
            BigPrize(prizeTh: prizeTh[0], prizeNum: "4152".convertStringToListOfStrings(), gradientColor: LinearGradient.orangeGradient)
            BigPrize(prizeTh: prizeTh[1], prizeNum: "5233".convertStringToListOfStrings(), gradientColor: LinearGradient.greenGradient)
            BigPrize(prizeTh: prizeTh[2], prizeNum: "9642".convertStringToListOfStrings(), gradientColor: LinearGradient.blueGradient)
            resultSection(title: "Special", results: specialResults)
            resultSection(title: "Consolation", results: consolationResults)
        }
    }
    
    private func resultSection(title: String, results: [Int]) -> some View {
        VStack(alignment: .leading) {
            CustomLabel(text: title)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(results, id: \.self) { result in
                    ResultCell(result: result)
                }
            }
            .padding(16)
            .background(Color.optionBtn1)
            .cornerRadius(10)
        }
    }
}

struct ResultCell: View {
    let result: Int
    
    var body: some View {
        Text("\(result)")
            .font(.caption)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(Color.optionBtn2)
            .cornerRadius(10)
            .foregroundStyle(.letters)
    }
}
struct BigPrize: View {
    var prizeTh: String
    var prizeNum: [String]
    var gradientColor: LinearGradient
    var textColor: Color = .letters
    
    var body: some View {
        VStack {
            CustomLabel(text: prizeTh, font: .caption, textColor: .white, alignment: .center)
            
            LotteryResultView(result: prizeNum, styleResult: .normal, lotCatID: 5, color: "white", backgroundColor: .clear, foregroudColor: .white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 100)
        .background(gradientColor)
        
        .cornerRadius(10)
    }
}


