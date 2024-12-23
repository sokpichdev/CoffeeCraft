// OGLayoutView.swift
// OneNews
//
// Created by Sok Pich on 12/19/24.
//

import SwiftUI

struct OGLayoutView: View {
    
    @ObservedObject var sportDateVM: SportDatesViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(sportDateVM.getDateArray().indices, id: \.self) { index in
                Button(action: {
                    if index == 6 {
                        sportDateVM.isDatePickerPresented = true
                    } else {
                        withAnimation {
                            sportDateVM.chosenDay = index
                            sportDateVM.selectedDate = sportDateVM.getDateArray()[index]
                            sportDateVM.isSelectedDate = false
//                            sportDateVM.updateMatchType(for: sportDateVM.getDateArray()[index])
                            print("Match Type: \(sportDateVM.matchType) - Selected Date: \(sportDateVM.selectedDate)")
                            
                        }
                    }
                }) {
                    if index == 6 {
                        CalendarIcon()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        let isToday = sportDateVM.matchType == .fixtures ? (index == 0) : (index == 5)
                        
                        DayView(day: isToday ? "Tod" : sportDateVM.getDateArray()[index].getDayName(),
                                date: sportDateVM.getDateArray()[index].formatDate())
                        .foregroundColor(sportDateVM.chosenDay == index ? .white : .letters)
                    }
                }
                .background(sportDateVM.chosenDay == index ? Color.main : Color.optionBtn2)
                .clipShape(Capsule())
                .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65) // Fixed size
            }
            
        }
    }
}

