//
//  LotteryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct LotteryView: View {
    @State var selectedCountry: Int = 1
    let countries = ["Cambodia", "China", "Thailand", "Malaysia", "Vietname", "Singapore"]
    let numbersList: [[Int]] = [
        [12, 1, 6, 33, 76, 19, 23, 23, 54, 22, 12, 66, 89, 34, 56, 78, 90, 45, 34, 11].shuffled(),
        [66, 89, 34].shuffled(),
        [76, 19, 23, 23, 51].shuffled(),
        [45, 34, 11].shuffled(),
        [12, 1, 6, 33, 76, 19, 23, 23, 54, 22].shuffled()
    ].shuffled()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<numbersList.count, id: \.self) { index in
                            NumbersCard(lists: numbersList[index])
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                HStack {
                    CustomLabel(text: "World Lotteries")
                    Spacer()
                    
                    Button(action: {}) {
                        Image(.filter)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 30, maxWidth: 40)
                    }
                }
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(countries.indices, id: \.self) { index in
                            CountriesButton(countryName: countries[index], isSelected: selectedCountry == index) {
                                withAnimation(.smooth){
                                    selectedCountry = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                HStack {
                    CustomLabel(text: "Lottery Results")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    Spacer()
                }
                
                ForEach(0..<numbersList.count, id: \.self) { index in
                    ResultView(lists: numbersList[index])
                }
            }
        }
        .background(Color.background)
    }
}
