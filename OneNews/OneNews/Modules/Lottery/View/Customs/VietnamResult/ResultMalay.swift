//
//  ResultMalay.swift
//  OneNews
//
//  Created by Sok Pich on 1/8/25.
//

import SwiftUI

struct ResultMalay: View {
    var lotCatID: Int
    var lotListID: Int
    var result: String
    var title: String
    var openDate: String
    var iconName: String
    var dn: String
    var selectedCountry: Int
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult(iconName: iconName, title: title, hasStatictAndGenerateNumver: true)
            
            ResultDetail(result: result.convertStringToListOfStrings(),
//                         lotCatID: lotCatID,
                             date: openDate,
                             dn: dn,
                             isSpecial: false)
            Spacer()
            MoreResultButton(lotListID: lotListID,icon: iconName, title: title, date: openDate, selectedCountry: selectedCountry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
    }
}
