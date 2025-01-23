//
//  TwentyNumberCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//
import SwiftUI

struct BaseNumbersCard<Content: View>: View {
    var title: String
    var openDate: String
    var index: Int
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(10)
            Divider().frame(height: 1).background(Color.white)

            Spacer()
            content()
            Spacer()
            
            HStack {
                Text("Result")
                    .font(.caption)
                Spacer()
                Text(openDate.formatDetailDate(type: .longDateDayTime) ?? "")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(10)
            .background(Color.black.opacity(0.15))
            .cornerRadius(15)
            .padding(10)
        }
        .foregroundStyle(Color.white)
        .frame(width: 300, height: 190)
        .background(dynamicBackground)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private var dynamicBackground: LinearGradient {
        if index % 2 == 0 {
            return Color.commonYellowCardGradientBg
        } else {
            return Color.commonRedCardGradientBg
        }
    }
}

struct NumbersCard: View {
    var result: CodeType?
    var title: String
    var openDate: String
    var index: Int
    
    var body: some View {
        BaseNumbersCard(title: title, openDate: openDate, index: index) {
            if case let .string(lottery) = result {
                LotteryResultView(result: lottery.convertStringToListOfStrings(), styleResult: .recommended)
            } else if case let .lottery7(lottery) = result {
                LotteryResultView(result: lottery.code?.convertStringToListOfStrings() ?? [""], styleResult: .recommended)
            } else if case let .lottery8(lottery) = result {
                LotteryResultView(result: lottery.code?.convertStringToListOfStrings() ?? [""], styleResult: .recommended)
            } else {
                NoDataView()
            }
        }
    }
}

struct NumbersCard1: View {
    var result: [String]
    var title: String
    var openDate: String
    var index: Int
    
    var body: some View {
        BaseNumbersCard(title: title, openDate: openDate, index: index) {
            LotteryResultView(result: result, styleResult: .recommended)
        }
    }
}
