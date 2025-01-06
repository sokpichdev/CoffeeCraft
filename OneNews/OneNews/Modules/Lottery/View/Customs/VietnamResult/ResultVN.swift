//
//  ResultVN.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultVN: View {
    var drawID: Int
    var result: String
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String

    @State private var isShowPrize: Bool = false
    @State var isSpecial: Bool = false
    var titleList = ["Special prize",
                  "First prize",
                  "Second prize",
                  "Third prize",
                  "Fourth prize",
                  "Fifth prize",
                  "Sixth prize",
                  "Seventh prize",
                  "Eighth prize"]
    
    // Function to extract prize data from the lottery result
//    var prizeData: [[String]] {
////        guard let detail = lotteryVM.lotteryVM.first?.result?.detail else {
////            return []
////        }
//
//        switch detail.code {
//        case .dictionary(let dict):
//            // Extract the keys and values from the dictionary and sort by keys
//            return dict.keys.sorted().compactMap { key in
//                if let value = dict[key]?.value {
//                    // If the value is a string, use convertStringToListOfStrings
//                    if let valueString = value as? String {
////                        return [valueString.convertStringToConcatenatedString(valueString)]
//                        return valueString.convertStringToListOfStrings(valueString)
//                    } else if let list = value as? [String] {
//                        return list
//                    }
//                }
//                return nil
//            }
//        case .string(let singleString):
//            return [[singleString]] // Handle the case where `code` is a single string
//        case .none:
//            return []
//        }
//    }

    
    var body: some View {
        VStack(spacing: 0) {
            SectionResult(iconName: iconName, title: title)
            ResultDetail(lists: result.convertStringToListOfStrings(result),
                         drawID: drawID,
                         date: openDate,
                         issue: issue,
                         officialIssue: officialIssue,
                         isSpecial: true)
            if isShowPrize {
                VStack(alignment: .center) {
                    Divider()
                    
                    // Loop through the prize data dynamically
//                    ForEach(prizeData.indices, id: \.self) { index in
//                        let prizeList = prizeData[index]
//                        let prizeTitle = titleList[index]
//                        PrizeTh(prizeTh: prizeTitle, prizeNumber: prizeList)
//                        Divider()
//                    }
                    // First and Second Prize
//                    HStack {
//                        PrizeTh(prizeTh: titleList[1], prizeNumber: prizeData[1])
//                        Divider().padding(.vertical, 5)
//                        PrizeTh(prizeTh: titleList[2], prizeNumber: prizeData[2])
//                    }
//                    
//                    Divider()
//                    PrizeTh(prizeTh: titleList[3], prizeNumber: prizeData[3])
//                    Divider()
//                    PrizeTh(prizeTh: titleList[4], prizeNumber: prizeData[4])
//                    Divider()
//                    PrizeTh(prizeTh: titleList[5], prizeNumber: prizeData[5])
//                    Divider()
//                    PrizeTh(prizeTh: titleList[6], prizeNumber: prizeData[6])
//                    Divider()
//                    
//                    if prizeData[0].count == 5{
//                        PrizeTh(prizeTh: titleList[7], prizeNumber: prizeData[7])
//                    } else {
//                        HStack {
//                            PrizeTh(prizeTh: titleList[7], prizeNumber: prizeData[7])
//                            Divider().padding(.vertical, 5)
//                            PrizeTh(prizeTh: titleList[8], prizeNumber: prizeData[8])
//                        }
//                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.letters.opacity(0.5))
                .background(Color.optionBtn2)
            }
            
            VStack {
                Button(action: { isShowPrize.toggle() }) {
                    ZStack {
                        Image(.polygon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 40)
                        CusImage(ImageName: isShowPrize ? "upBtn" : "downBtn")
                            .foregroundStyle(.letters)
                    }
                }
                MoreResultButton()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.optionBtn1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn1)
        .cornerRadius(5)
        .padding(.horizontal, 16)
    }
}
