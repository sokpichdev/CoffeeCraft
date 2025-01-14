//
//  MoreResultsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct MoreResultsView: View {
    @StateObject var lotteryResultVM = LotteryResultViewModel()
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
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
                        // Handle other actions
                    }) {
                        Image(.whiteStar)
                            .padding(10)
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(5)
                    }
                    Button(action: {
                        showDatePicker.toggle()
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
                            ResultVN(lotListID: lotteryResultVM.lRVM[index].lotteryListID ?? 0,
                                     result: lotteryResultVM.lRVM[index].detail?.code,
                                     title: "",
                                     openDate: lotteryResultVM.lRVM[index].openDate ?? "",
                                     iconName: "",
                                     issue: lotteryResultVM.lRVM[index].detail?.issue ?? "",
                                     officialIssue: lotteryResultVM.lRVM[index].detail?.officialissue ?? "",
                                     selectedCountry: selectedCountry,
                                     hasButton: false)
                        }
                    } else if selectedCountry == 5 {
                        if let result = lotteryResultVM.lRVM.first(where: { $0.lotteryListID == lotListID }) {
                            ResultMalayDetail(detail: result.detail, date: result.openDate ?? "", issue: result.detail?.issue ?? "")
                        }
                    }
                } else {
                    NoDataView()
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.background)
        .onAppear() { lotteryResultVM.fetchLotteryList(lotteryListID: lotListID, date: date.formatDetailDate(type: .DateOnly) ?? "") }
        .onChange(of: selectedDate) { newDate in  lotteryResultVM.fetchLotteryList(lotteryListID: lotListID, date: newDate.formattedAsDateOnly()) }
        .sheet(isPresented: $showDatePicker) { GeneralDatePickerSheet(selectedDate: $selectedDate) }
    }
}




