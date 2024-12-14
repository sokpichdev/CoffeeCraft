//
//  LotteryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct LotteryView: View {
    @State var selectedCountry: Int = 4
    let countries = ["Cambodia", "China", "Thailand", "Malaysia", "Vietnam", "Singapore"]
    let numbersList: [[Int]] = [
        [12, 1, 6, 33, 76, 19, 23, 23, 54, 22, 12, 66, 89, 34, 56, 78, 90, 45, 34, 11].shuffled(),
        [66, 89, 34].shuffled(),
        [76, 19, 23, 23, 51].shuffled(),
        [45, 34, 11].shuffled(),
        [12, 1, 6, 33, 76, 19, 23, 23, 54, 22].shuffled()
    ].shuffled()
    
    var body: some View {
        ScrollView {
            VStack {
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
                    
                    NavigationLink(destination: FilterView()) {
                        Image(.filter)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Set a fixed size
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
                    if selectedCountry == 1 {
                        ResultView(lists: numbersList[index])
                    } else if selectedCountry == 4 {
                        ResultVN(lists: numbersList[index])
                    } else {
                        ResultView(lists: numbersList[index])

                    }
                }
            }
        }
        .background(Color.background)
    }
}
