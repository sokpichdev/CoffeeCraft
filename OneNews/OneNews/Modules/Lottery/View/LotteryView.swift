//
//  LotteryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//
///
//  LotteryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct LotteryView: View {
    @StateObject var lotteryVM = LotteryViewModel()
    @StateObject var countryVM = CountryViewModel()
    @StateObject var recommededLotteryVM = RecommendedLotteryViewModel()
    @State var selectedCountry: Int = 3

    var body: some View {
        ScrollView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if !recommededLotteryVM.rLVM.isEmpty {
                            ForEach(recommededLotteryVM.rLVM.indices, id: \.self) { index in
                                NumbersCard(
                                    lists: recommededLotteryVM.rLVM[index].result?.detail?.code,
//                                    lists: "2,1,5,2,5",
                                    title: recommededLotteryVM.rLVM[index].title ?? "",
                                    openDate: recommededLotteryVM.rLVM[index].openDate ?? ""
                                )
                            }
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
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(countryVM.countryVM.indices, id: \.self) { index in
                            if let countryName = countryVM.countryVM[index].country?.name {
                                CountriesButton(countryName: countryName,
                                                numberOfLottery: countryVM.countryVM[index].country?.lotteriesCount ?? 0,
                                                isSelected: selectedCountry == index) {
                                    withAnimation(.smooth) {
                                        selectedCountry = countryVM.countryVM[index].countryID ?? 0
                                        print("Country name: \(countryName) - country id: \(countryVM.countryVM[index].countryID ?? 0)")
                                    }
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
                if !lotteryVM.lotteryVM.isEmpty {
                    if selectedCountry == 3 {
                        ForEach(lotteryVM.lotteryVM.indices, id: \.self) { index in
                            let lottery = lotteryVM.lotteryVM[index]
                            ResultView(drawID: lottery.id ?? 0,
                                       result: lottery.result?.detail?.code,
//                                       result: "1,2,5,7,3,2,2",
                                       title: lottery.title ?? "",
                                       openDate: lottery.openDate ?? "",
                                       iconName: lottery.icon ?? "",
                                       issue: lottery.result?.detail?.issue ?? "",
                                       officialIssue: lottery.result?.detail?.officialissue ?? ""
                            )
                        }
                    } else if selectedCountry == 4 {
                        ForEach(lotteryVM.lotteryVM.indices, id: \.self) { index in
                                let lottery = lotteryVM.lotteryVM[index]
//                                ResultVN(drawID: lottery.id ?? 0,
//                                         result: lottery.result?.detail?.code.lottery7 ?? "",
////                                         result: "1,2,3,4,5,6,7",
//                                         title: lottery.title ?? "",
//                                         openDate: lottery.openDate ?? "",
//                                         iconName: lottery.icon ?? "",
//                                         issue: lottery.result?.detail?.issue ?? "",
//                                         officialIssue: lottery.result?.detail?.officialissue ?? "",
//                                         isSpecial: true)
                        }
                    } else if selectedCountry == 5 {
                        NoDataView()
                    } else {
                        NoDataView()
                    }
                }
            }
        }
        .background(Color.background)
        .onAppear {
            countryVM.fetchCountry()
            lotteryVM.fetchLottery(countryID: selectedCountry)
            recommededLotteryVM.fetchLottery(countryID: selectedCountry)
        }
        .onChange(of: selectedCountry) { _ in
            lotteryVM.fetchLottery(countryID: selectedCountry)
            recommededLotteryVM.fetchLottery(countryID: selectedCountry)
        }
    }
}
