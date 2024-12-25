//
//  ResultVN.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultVN: View {
    @State var lists: [Int] = [] // Changed to 1D array
    @State var isShowPrize: Bool = false
    @State var isSpecial: Bool = false

    let prizeData: [[Int]] = [
        [13423], // 1st prize
        [25368, 93453], // 2nd prize
        [12211, 55543, 63427, 23423, 54333], // 3rd prize
        [1343, 8765, 3466], // 4th prize
        [2343, 7774, 1680, 9898], // 5th prize
        [123, 555, 744 ,374], // 6th prize
        [23, 54, 10, 43, 99], // 7th prize
        [23, 54, 66, 36, 98, 11] // 8th prize
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            SectionResult(imageName: Image(.result1))
            ResultDetail(lists: [12, 1, 6, 33, 76, 23].shuffled(), isSpecial: true)
            
            if isShowPrize {
                VStack(alignment: .center) {
                    Divider()
                    
                    // First and Second Prize
                    HStack {
                        PrizeTh(prizeTh: "First prize", prizeNumber: prizeData[0])
                        Divider().padding(.vertical, 5)
                        PrizeTh(prizeTh: "Second prize", prizeNumber: prizeData[1])
                    }
                    
                    Divider()
                    PrizeTh(prizeTh: "Third prize", prizeNumber: prizeData[2])
                    Divider()
                    PrizeTh(prizeTh: "Fourth prize", prizeNumber: prizeData[3])
                    Divider()
                    PrizeTh(prizeTh: "Fifth prize", prizeNumber: prizeData[4])
                    Divider()
                    PrizeTh(prizeTh: "Sixth prize", prizeNumber: prizeData[5])
                    Divider()
                    
                    // Check the count of 'lists' to decide on prizes
                    if prizeData.count == 5 {
                        PrizeTh(prizeTh: "Seventh prize", prizeNumber: prizeData[6])
                    } else {
                        HStack {
                            PrizeTh(prizeTh: "Seventh prize", prizeNumber: prizeData[6])
                            Divider().padding(.vertical, 5)
                            PrizeTh(prizeTh: "Eighth prize", prizeNumber: prizeData[7])
                        }
                    }
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

#Preview {
    ResultVN()
}
