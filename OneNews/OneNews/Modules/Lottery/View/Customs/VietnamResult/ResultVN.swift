//
//  ResultVN.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultVN: View {
    var lotCatID: Int
    var result: CodeType?
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
//    private var code,code1, code2, code3, code4, code5, code6, code7, code8: String?

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

    var body: some View {
        VStack(spacing: 0) {
            SectionResult(iconName: iconName, title: title, hasStatictAndGenerateNumver: false)
            if case let .lottery7(lottery) = result{
                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
                             lotCatID: lotCatID,
                             date: openDate,
                             issue: issue,
                             officialIssue: officialIssue,
                             isSpecial: true)
            }
            if case let .lottery8(lottery) = result{
                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
                             lotCatID: lotCatID,
                             date: openDate,
                             issue: issue,
                             officialIssue: officialIssue,
                             isSpecial: true)
            }
            if isShowPrize {
                VStack(alignment: .center) {
                    Divider()
                    // First and Second Prize
                    if case let .lottery7(lottery) = result{
                        HStack {
                            PrizeThArray(prizeTh: titleList[1], prizeNumber: lottery.code1?.convertconcatedStrToListOfStr() ?? [])
                            Divider().padding(.vertical, 5)
                            PrizeThArray(prizeTh: titleList[2], prizeNumber: lottery.code2 ?? [])
                        }
                        
                        Divider()
                        PrizeThArray(prizeTh: titleList[3], prizeNumber: lottery.code3 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[4], prizeNumber: lottery.code4 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[5], prizeNumber: lottery.code5 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[6], prizeNumber: lottery.code6 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[7], prizeNumber: lottery.code7 ?? [])
                        
                    }
                    
                    if case let .lottery8(lottery) = result {
                        HStack {
                            PrizeThArray(prizeTh: titleList[1],
                                         prizeNumber: lottery.code1?.convertconcatedStrToListOfStr() ?? [])
                            Divider().padding(.vertical, 5)
                            PrizeThArray(prizeTh: titleList[2],
                                         prizeNumber: lottery.code2?.convertconcatedStrToListOfStr() ?? [])
                        }
                        
                        Divider()
//                        PrizeTh(prizeTh: titleList[3], prizeNumber: lottery.code3 ?? "")
                        PrizeThArray(prizeTh: titleList[3], prizeNumber: lottery.code3 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[4], prizeNumber: lottery.code4 ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[5],
                                     prizeNumber: lottery.code5?.convertconcatedStrToListOfStr() ?? [])
                        Divider()
                        PrizeThArray(prizeTh: titleList[6], prizeNumber: lottery.code6 ?? [])
                        Divider()
                        HStack {
                            PrizeThArray(prizeTh: titleList[7],
                                         prizeNumber: lottery.code7?.convertconcatedStrToListOfStr() ?? [])
                            Divider().padding(.vertical, 5)
                            PrizeThArray(prizeTh: titleList[8],
                                         prizeNumber: lottery.code8?.convertconcatedStrToListOfStr() ?? [])

                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.letters.opacity(0.5))
                .background(Color.optionBtn2)
            }
            
            VStack {
                Button(action: { withAnimation{isShowPrize.toggle()} }) {
                    ZStack {
                        Image(.polygon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 40)
                        CusImage(ImageName: isShowPrize ? "upBtn" : "downBtn")
                            .foregroundStyle(.letters)
                    }
                }
                if isShowPrize {
                    MoreResultButton()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isShowPrize ? Color.optionBtn1: Color.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn1)
        .cornerRadius(5)
        .padding(.horizontal, 16)
    }

}
