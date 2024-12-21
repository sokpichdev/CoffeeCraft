// SelectedDateView.swift
// OneNews
//
// Created by Sok Pich on 12/19/24.
//
import SwiftUI

struct SelectedDateView: View {
    @ObservedObject var sportDateVM: SportDatesViewModel

    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut) {
                    sportDateVM.selectedDate = sportDateVM.today // Return back to original layout.
//                    sportDateVM.updateMatchType(for: nil)
                    sportDateVM.isSelectedDate = false
//                    sportDateVM.chosenDay =  0
                    if sportDateVM.matchType == .fixtures {
                        sportDateVM.chosenDay = 0
                    } else {
                        sportDateVM.chosenDay = 5
                    }
                    print("Match Type: \(sportDateVM.matchType) - Selected Date: \(sportDateVM.selectedDate)")
                }
            }) {
                let isToday = sportDateVM.matchType == .fixtures ? 0 : 5
                DayView(day: "Tod", date: sportDateVM.getDateArray()[isToday].formatDate())
                    .background(Color.optionBtn2)
                    .foregroundColor(/*sportDateVM.chosenDay == 0 ? .white : */.letters)
                    .clipShape(Capsule())
            }
            .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65) // Fixed size
            
            VStack {
                HStack {
                    Button(action: { sportDateVM.adjustDate(by: -1) }) {
                        Image(.backBtn)
                    }
                    Spacer()
                    Text(sportDateVM.selectedDate.formattedAsDateOnly())
                        .font(.subheadline)
                    Spacer()
                    Button(action: { sportDateVM.adjustDate(by: 1) }) {
                        Image(.frontBtn)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(Color.main)
            .foregroundColor(.letters)
            .clipShape(Capsule())
            
            Button(action: {
                sportDateVM.isDatePickerPresented = true
            }) {
                VStack {
                    CalendarIcon()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.optionBtn2)
                .clipShape(Capsule())
            }
            .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65) // Fixed size
        }
    }
}
