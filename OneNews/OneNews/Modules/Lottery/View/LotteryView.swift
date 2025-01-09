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
//    @State var currentPage: Int = 1
    var body: some View {
        ScrollView {
            LazyVStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if !recommededLotteryVM.rLVM.isEmpty {
                            ForEach(recommededLotteryVM.rLVM.indices, id: \.self) { index in
                                
                                if selectedCountry != 5 {
                                    NumbersCard(
                                        result: recommededLotteryVM.rLVM[index].result?.detail?.code,
                                        title: recommededLotteryVM.rLVM[index].title ?? "",
                                        openDate: recommededLotteryVM.rLVM[index].openDate ?? "",
                                        index: index
                                    )
                                } else {
                                    NumbersCard1(
                                        result: recommededLotteryVM.rLVM[index].result?.detail?.p1?.convertStringToListOfStrings() ?? [""],
                                        title: recommededLotteryVM.rLVM[index].title ?? "",
                                        openDate: recommededLotteryVM.rLVM[index].openDate ?? "",
                                        index: index
                                    )
                                }
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
                                                isSelected: .constant(selectedCountry == (countryVM.countryVM[index].countryID ?? 0))) {
                                    withAnimation(.smooth) {
                                        selectedCountry = countryVM.countryVM[index].countryID ?? 0
//                                        lotteryVM.fetchLottery(countryID: selectedCountry, pageNo: 1)
//                                        recommededLotteryVM.fetchLottery(countryID: selectedCountry)
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
                            if lottery.lotteryCategoryID != 3 {
                                ResultView(lotCatID: lottery.lotteryCategoryID ?? 0,
                                           result: lottery.result?.detail?.code,
                                           title: lottery.title ?? "",
                                           openDate: lottery.openDate ?? "",
                                           iconName: lottery.icon ?? "",
                                           issue: lottery.result?.detail?.issue ?? "",
                                           officialIssue: lottery.result?.detail?.officialissue ?? "",
                                           isSpecial: false)
                            } else {
                                ResultLottoView(lotCatID: lottery.lotteryCategoryID ?? 0,
                                                attrs: lottery.result?.detail?.attrs ?? [],
                                                title: lottery.title ?? "",
                                                openDate: lottery.openDate ?? "",
                                                iconName: lottery.icon ?? "",
                                                issue: lottery.result?.detail?.issue ?? "",
                                                officialIssue: lottery.result?.detail?.officialissue ?? "",
                                                isSpecial: false)
                            }
                            if index == lotteryVM.lotteryVM.count - 1 {
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            lotteryVM.loadMore(countryID: selectedCountry)
                                        }
                                }
                                .frame(height: 1)
                            }
                        }
                    } else if selectedCountry == 4 {
                        ForEach(lotteryVM.lotteryVM.indices, id: \.self) { index in
                            let lottery = lotteryVM.lotteryVM[index]
                            ResultVN(lotCatID: lottery.id ?? 0,
                                     result: lottery.result?.detail?.code,
                                     title: lottery.title ?? "",
                                     openDate: lottery.openDate ?? "",
                                     iconName: lottery.icon ?? "",
                                     issue: lottery.result?.detail?.issue ?? "",
                                     officialIssue: lottery.result?.detail?.officialissue ?? "",
                                     isSpecial: true
                            )
                            if index == lotteryVM.lotteryVM.count - 1 {
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            lotteryVM.loadMore(countryID: selectedCountry)
                                        }
                                }
                                .frame(height: 1)
                            }
                        }
                    } else if selectedCountry == 5 {
                        ForEach(lotteryVM.lotteryVM.indices, id: \.self) { index in
                            let lottery = lotteryVM.lotteryVM[index]
                            ResultMalay(lotCatID: lottery.id ?? 0,
                                        result: lottery.result?.detail?.p1 ?? "",
                                        title: lottery.title ?? "",
                                        openDate: lottery.openDate ?? "",
                                        iconName: lottery.icon ?? "",
                                        issue: lottery.result?.detail?.issue ?? "",
                                        officialIssue: lottery.result?.detail?.officialissue ?? ""
                             )
                            if index == lotteryVM.lotteryVM.count - 1 {
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            lotteryVM.loadMore(countryID: selectedCountry)
                                        }
                                }
                                .frame(height: 1)
                            }
                        }
                    } else {
                        NoDataView()
                    }
                }
            }
        }
        .background(Color.background)
        .onAppear {
            countryVM.fetchCountry()
            lotteryVM.fetchLottery(countryID: selectedCountry, pageNo: lotteryVM.currentPage)
            recommededLotteryVM.fetchLottery(countryID: selectedCountry)
        }
        .onChange(of: selectedCountry) { _ in
            lotteryVM.lotteryVM.removeAll()
            lotteryVM.fetchLottery(countryID: selectedCountry, pageNo: lotteryVM.currentPage)
            recommededLotteryVM.fetchLottery(countryID: selectedCountry)
        }
    }
}
