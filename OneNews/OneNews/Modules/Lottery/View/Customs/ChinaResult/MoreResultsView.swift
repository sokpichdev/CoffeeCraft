//
//  MoreResultsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct MoreResultsView: View {
    @StateObject var lotteryResultVM = LotteryResultViewModel()
    var lotListID: Int
    var icon: String
    var title: String
    var date: String
    var selectedCountry: Int
    var body: some View {
        ScrollView {
            CustomNavigation(title: "Lottery Results")
            VStack {
                HStack(spacing: 5) {
                    Image(.result)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .leading)
                    
                    CustomLabel(text: title, textColor: .white, alignment: .center)
                    
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(.whiteStar)
                            .padding(10)
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(5)
                    }
                    Button(action: {
                        
                    }) {
                        Image(.whiteCalendar)
                            .padding(10)
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(5)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                
                .padding(.horizontal, 16)
                .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(5)
                
                if !lotteryResultVM.lRVM.isEmpty {
                    if selectedCountry == 3 {
                        ForEach(lotteryResultVM.lRVM, id: \.id) { result in
                            if let detail = result.detail, case let .string(lottery) = detail.code {
                                ResultDetail(result: lottery.convertStringToListOfStrings(),
                                             date: result.openDate ?? "",
                                             issue: detail.issue ?? "",
                                             officialIssue: detail.officialissue ?? "",
                                             isSpecial: false)
                            }
                        }
                    } else if selectedCountry == 4 {
                        ForEach(lotteryResultVM.lRVM.indices, id: \.self) { index in
                            if case let .lottery7(lottery) = lotteryResultVM.lRVM[index].detail?.code{
                                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
                                             date: lotteryResultVM.lRVM[index].openDate ?? "",
                                             issue: lotteryResultVM.lRVM[index].detail?.issue ?? "",
                                             officialIssue: lotteryResultVM.lRVM[index].detail?.officialissue ?? "",
                                             isSpecial: true)
                            } else if case let .lottery8(lottery) = lotteryResultVM.lRVM[index].detail?.code{
                                ResultDetail(result: lottery.code?.convertStringToListOfStrings() ?? [""],
                                             date: lotteryResultVM.lRVM[index].openDate ?? "",
                                             issue: lotteryResultVM.lRVM[index].detail?.issue ?? "",
                                             officialIssue: lotteryResultVM.lRVM[index].detail?.officialissue ?? "",
                                             isSpecial: true)
                            }
                        }
                    } else if selectedCountry == 5 {
                        ResultMalayDetail()
                    }

                }
            }
            .padding(.horizontal, 16)
            
        }
        .background(Color.background)
        .onAppear() {
            lotteryResultVM.fetchLotteryList(lotteryListID: lotListID,
                                             date: date.formatDetailDate(type: .DateOnly) ?? "")
        }
    }
}

