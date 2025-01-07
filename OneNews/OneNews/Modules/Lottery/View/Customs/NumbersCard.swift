//
//  TwentyNumberCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//
import SwiftUI

struct NumbersCard: View {
    //    @State var lists: [Int] = [] // Changed to 1D array
    var result: CodeType?
    var title: String
    var openDate: String
    var body: some View {
        VStack {
            // Header
            HStack {
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(10)
            Divider().frame(height: 1).background(Color.white)

            Spacer()
            
            if case let .string(lottery) = result {
                LotteryResultView(result: lottery, styleResult: .recommended)
            } else if case let .lottery7(lottery) = result {
                LotteryResultView(result: lottery.code ?? "", styleResult: .recommended)
            } else if case let .lottery8(lottery) = result {
                LotteryResultView(result: lottery.code ?? "", styleResult: .recommended)
            } else {
                NoDataView()
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Result")
                    .font(.caption)
                Spacer()
                Text(openDate.formatDetailDate(from: openDate, type: .longDateDayTime) ?? "")
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
    
    private var cardColors: [LinearGradient] {
        [
            LinearGradient(gradient: Gradient(colors: [Color.lightRed, Color.darkRed]), startPoint: .top, endPoint: .bottom),
            LinearGradient(gradient: Gradient(colors: [Color.lightPink, Color.darkPink]), startPoint: .top, endPoint: .bottom),
            LinearGradient(gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]), startPoint: .top, endPoint: .bottom),
            LinearGradient(gradient: Gradient(colors: [Color.lightYellow, Color.darkYellow]), startPoint: .top, endPoint: .bottom),
            LinearGradient(gradient: Gradient(colors: [Color.lightBlueBerry, Color.darkBlueBerry]), startPoint: .top, endPoint: .bottom)
        ]
    }

    private var dynamicBackground: LinearGradient {
        let index = abs(openDate.hashValue) % cardColors.count
        return cardColors[index]
    }


    
}

