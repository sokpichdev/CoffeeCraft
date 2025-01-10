//
//  ResultView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct ResultView: View {
    var lotCatID: Int
    var lotListID: Int
    var result: CodeType?
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
    var isSpecial: Bool = true
    var selectedCountry: Int
    var action:(() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult(iconName: iconName, title: title, hasStatictAndGenerateNumver: false)
            
            if case let .string(lottery) = result {
                ResultDetail(result: lottery.convertStringToListOfStrings(),
                             date: openDate,
                             issue: issue,
                             officialIssue: officialIssue,
                             isSpecial: false)
            }
            Spacer()
            Button(action: {
                action?()
            }) {
                MoreResultButton(lotListID: lotListID, icon: iconName, title: title, date: openDate,selectedCountry: selectedCountry)
            }

            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
        
    }
}
struct ResultLottoView: View {
    var lotCatID: Int
    var lotListID: Int
    var attrs: [Attrs]
    var title: String
    var openDate: String
    var iconName: String
    var issue: String
    var officialIssue: String
    var isSpecial: Bool = true
    var selectedCountry: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult(iconName: iconName, title: title, hasStatictAndGenerateNumver: false)
            VStack {
                Text("DRAW ID - \(issue + officialIssue)")
                    .font(.caption)
                    .foregroundColor(Color.letters.opacity(0.5))
                
                HStack {
                    Text(openDate.formatDetailDate(type: .day) ?? "").fontWeight(.bold)
                    Text(" | ")
                    Text(openDate.formatDetailDate(type: .longDateTime) ?? "")
                }
                .font(.caption)
                .frame(height: 12)
                
                if isSpecial {
                    Text("Special Prize").foregroundStyle(.main).fontWeight(.semibold)
                } else {
                    Text("")
                }
                HStack(spacing: 5) {
                    ForEach(Array(attrs.enumerated()), id: \.0) { index, row in
                        if index == 6 {
                            CircleViewForStyle(number: "+",
                                               color: "optionBtn2",
                                               styleResult: .normal,
                                               lotteryCategoryID: lotCatID)
                        }
                        CircleViewForStyle(number: row.num ?? "",
                                           color: row.color ?? "main",
                                           animal: row.animal ?? "",
                                           styleResult: .normal,
                                           lotteryCategoryID: lotCatID)
//
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
            .background(Color.optionBtn2)
            
            Spacer()
            MoreResultButton(lotListID: lotCatID, icon: iconName, title: title, date: openDate, selectedCountry: selectedCountry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
    }
}

