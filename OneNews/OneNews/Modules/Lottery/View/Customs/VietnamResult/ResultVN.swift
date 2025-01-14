//
//  ResultVN.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultVN: View {
    var lotListID: Int
    var result: CodeType?
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
    var selectedCountry: Int
    var hasButton: Bool = true
    
    @State private var isShowPrize: Bool = false
    var titleList = ["Special prize", "First prize", "Second prize", "Third prize",  "Fourth prize", "Fifth prize", "Sixth prize", "Seventh prize", "Eighth prize"]
    
    var body: some View {
        VStack(spacing: 0) {
            if case let .lottery7(lottery) = result{
                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
                             date: openDate,
                             issue: issue,
                             officialIssue: officialIssue,
                             isSpecial: true)
            } else if case let .lottery8(lottery) = result{
                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
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
                            PrizeView(prizeTh: titleList[1], prizeString: lottery.code1 ?? "")
                            Divider().padding(.vertical, 5)
                            PrizeView(prizeTh: titleList[2], prizeArray: lottery.code2 ?? [])
                        }
                        Divider()
                        PrizeView(prizeTh: titleList[3], prizeArray: lottery.code3 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[4], prizeArray: lottery.code4 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[5], prizeArray: lottery.code5 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[6], prizeArray: lottery.code6 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[7], prizeArray: lottery.code7 ?? [])
                    }
                    if case let .lottery8(lottery) = result {
                        HStack {
                            PrizeView(prizeTh: titleList[1], prizeString: lottery.code1 ?? "")
                            Divider().padding(.vertical, 5)
                            PrizeView(prizeTh: titleList[2], prizeString: lottery.code2 ?? "")
                        }
                        Divider()
                        PrizeView(prizeTh: titleList[3], prizeArray: lottery.code3 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[4], prizeArray: lottery.code4 ?? [])
                        Divider()
                        PrizeView(prizeTh: titleList[5], prizeString: lottery.code5 ?? "")
                        Divider()
                        PrizeView(prizeTh: titleList[6], prizeArray: lottery.code6 ?? [])
                        Divider()
                        HStack {
                            PrizeView(prizeTh: titleList[7], prizeString: lottery.code7 ?? "")
                            Divider().padding(.vertical, 5)
                            PrizeView(prizeTh: titleList[8], prizeString: lottery.code8 ?? "")
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
                if hasButton {
                    MoreResultButton(lotListID: lotListID, icon: iconName, title: title, date: openDate, selectedCountry: selectedCountry)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hasButton ? Color.optionBtn1 : Color.background)
        }
    }
}
