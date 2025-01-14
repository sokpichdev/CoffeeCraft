//
//  ResultMalayDetail.swift
//  OneNews
//
//  Created by Sok Pich on 1/13/25.
//

import SwiftUI

struct ResultMalayDetail: View {
    let detail: Detail?
    let date: String
    let issue: String
    
    let prizeTh = ["1st PRIZE", "2nd PRIZE", "3rd PRIZE"]
    
    var body: some View {
        VStack {
            HStack {
                Text("DRAW ID - \(detail?.dn ?? "")")
                Spacer()
                Text(date.formatDetailDate(type: .ddMMMMyyyyEEEE) ?? "")
            }
            .font(.caption)
            .frame(height: 12)
            
            if let detail = detail {
                BigPrize(prizeTh: prizeTh[0], prizeNum: detail.p1?.convertStringToListOfStrings() ?? [], gradientColor: LinearGradient.orangeGradient)
                BigPrize(prizeTh: prizeTh[1], prizeNum: detail.p2?.convertStringToListOfStrings() ?? [], gradientColor: LinearGradient.greenGradient)
                BigPrize(prizeTh: prizeTh[2], prizeNum: detail.p3?.convertStringToListOfStrings() ?? [], gradientColor: LinearGradient.blueGradient)
                
                resultSection(title: "Special", results: getSpecialResults(from: detail))
                resultSection(title: "Consolation", results: getConsolationResults(from: detail))
            }
        }
    }
    
    private func resultSection(title: String, results: [String]) -> some View {
        VStack(alignment: .leading) {
            CustomLabel(text: title)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                ForEach(results, id: \.self) { result in
                    ResultCell(result: result)
                }
            }
            .padding(16)
            .background(Color.optionBtn1)
            .cornerRadius(10)
        }
    }
    
    private func getSpecialResults(from detail: Detail) -> [String] {
        return [detail.s1, detail.s2, detail.s3, detail.s4, detail.s5, detail.s6, detail.s7, detail.s8, detail.s9, detail.s10, detail.s11, detail.s12, detail.s13]
            .compactMap { $0 }  // Remove nil values
            .filter { $0.isNumber }  // Keep only valid numeric strings
    }

    private func getConsolationResults(from detail: Detail) -> [String] {
        return [detail.c1, detail.c2, detail.c3, detail.c4, detail.c5, detail.c6, detail.c7, detail.c8, detail.c9, detail.c10]
            .compactMap { $0 }
            .filter { $0.isNumber }
    }

}


struct ResultCell: View {
    let result: String
    
    var body: some View {
        Text(result)
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


