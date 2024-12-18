//
//  SportsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct SportsView: View {
    @ObservedObject var recommendedVM = RecommendedMatchesViewModel()
    @State  var chosenDay: Int = 1 /// track the selected day
    @State private var selectedFootball: Bool = true
    @State private var isDateSelected: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @State  var selectedDate: Date? = nil /// to track the selected date from the date picker
    
    @State private var isLoading = true // Tracks if the card is still loading
    
    
    let  calendar = Calendar.current
    let today = Date()
    
    var daysAndDate: [(day: String, date: Int)] { /// return an array of tuples
        var daysArray: [(String, Int)] = [] // empty array to store tuples
        for offset in -1..<6 { /// loop from -1 to 6. -1 for Ytd, 0 for today, 1...5 for next days
            if let date = calendar.date(byAdding: .day, value: offset, to: today) { /// calculate a new date by adding offset days to the today date:
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) -  1]
                ///  calendar.component(.weekday, from: date) retrieves the day of the week an integers (1 = Sunday, 2 = Monday, ...).
                ///  calendar.shortWeekdaySymbols is na array of short weekday names: ["Sun", "Mon"...]
                ///  -1 maps the weekdays integer to the correct index in shortWeekdaySymbols
                let dayNumber = calendar.component(.day, from: date) /// Extracts the day number of the month (e.g., 9 for December 9th)
                daysArray.append((dayName, dayNumber)) /// Adds the typle (dayName, dayNumber) to the daysArray.
            }
        }
        return daysArray /// Returns the array of tuples.
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() { // Adjust the spacing as needed
                        if selectedFootball {
                            if !recommendedVM.recommended.isEmpty {
                                ForEach(recommendedVM.recommended, id: \.id) { recommended in
                                    TeamCard(
                                        title: recommended.league?.name ?? "",
                                        leftTeamImage: recommended.homeTeam?.logoPath ?? "",
                                        leftTeamName: recommended.homeTeam?.name ?? "",
                                        leftTeamScore: recommended.homeTeamScore ?? "",
                                        rightTeamImage: recommended.awayTeam?.logoPath ?? "",
                                        rightTeamName: recommended.awayTeam?.name ?? "",
                                        rightTeamScore: recommended.awayTeamScore ?? "",
                                        timer: recommended.timer ?? "",
                                        formattedDateTime: recommended.formattedDateTime ?? "",
                                        isLive: false
                                    )
                                    .padding(.horizontal, 16) // avoid padding the scrollView
                                }
                                
                            }
                        } else {
                            if !recommendedVM.recommended.isEmpty {
                                ForEach(recommendedVM.recommended, id: \.id) { recommended in
                                    TeamCard(
                                        title: recommended.league?.name ?? "",
                                        leftTeamImage: recommended.homeTeam?.logoPath ?? "",
                                        leftTeamName: recommended.homeTeam?.name ?? "",
                                        leftTeamScore: recommended.homeTeamScore ?? "",
                                        rightTeamImage: recommended.awayTeam?.logoPath ?? "",
                                        rightTeamName: recommended.awayTeam?.name ?? "",
                                        rightTeamScore: recommended.awayTeamScore ?? "",
                                        timer: recommended.timer ?? "",
                                        formattedDateTime: recommended.formattedDateTime ?? "",
                                        isLive: false
                                    )
                                    .padding(.horizontal, 16) // avoid padding the scrollView
                                }
                                
                            }
                        }
                    }
                }
                optionButtons
                
                CustomLabel(text: selectedFootball ? "Football Matches" : "Basketball Matches")
                    .padding(.horizontal, 16)
                
                dateButtons
                
                
//                if chosenDay == 1{
//                    if !recommendedVM.recommended.isEmpty {
//                        ForEach(recommendedVM.recommended, id: \.id) { rcmd in
//                            LiveMatch(leftTeamImage: rcmd.homeTeam?.logoPath ?? "",
//                                      leftTeamName: rcmd.homeTeam?.name ?? "",
//                                      leftTeamScore: rcmd.homeTeamScore ?? "",
//                                      rightTeamImage: rcmd.awayTeam?.logoPath ?? "",
//                                      rightTeamName: rcmd.awayTeam?.name ?? "",
//                                      rightTeamScore: rcmd.awayTeamScore ?? ""
//                                      )
//                        }
//                    } else {
//                        Text("NO DATA")
//                    }
//                } else if chosenDay < 1 {
//                    if !recommendedVM.recommended.isEmpty {
//                        ForEach(recommendedVM.recommended, id: \.id) { rmcd in
//                            FinishedMatch(leftTeamImage: rcmd.homeTeam?.logoPath ?? "",
//                                          leftTeamName: rcmd.homeTeam?.name ?? "",
//                                          leftTeamScore: rcmd.homeTeamScore ?? "",
//                                          rightTeamImage: rcmd.awayTeam?.logoPath ?? "",
//                                          rightTeamName: rcmd.awayTeam?.name ?? "",
//                                          rightTeamScore: rcmd.awayTeamScore ?? ""
//                                        )
//                        }
//                    }
//                } else {
//                    if !recommendedVM.recommended.isEmpty {
//                        ForEach(recommendedVM.recommended, id: \.id) { rmcd in
//                            UpcomingMatch(leftTeamImage: rcmd.homeTeam?.logoPath ?? "",
//                                          leftTeamName: rcmd.homeTeam?.name ?? "",
//                                          rightTeamImage: rcmd.awayTeam?.logoPath ?? "",
//                                          rightTeamName: rcmd.awayTeam?.name ?? ""
//                                        )
//                        }
//                    }
//                }
            }
            .onAppear() {
                recommendedVM.fetchJournals(sportID: selectedFootball ? 1 : 2)
            }
            .onChange(of: selectedFootball) { newValue in
                recommendedVM.fetchJournals(sportID: newValue ? 1 : 2)
            }
            .background(Color.background) // background for all
            Spacer()
        }
        
    }
    
    private var optionButtons: some View {
        HStack { // buttons
            CustomOptionButtons(
                title: "Football",
                imageName: "Football",
                isSelected: selectedFootball
            ) {
                selectedFootball = true
            }
            
            CustomOptionButtons(
                title: "Basketball",
                imageName: "Basketball",
                isSelected: !selectedFootball
            ) {
                selectedFootball = false
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    
    private var dateButtons: some View {
        HStack(spacing: 10) {
            if let selectedDate = selectedDate {
                Button(action: { // Button to reset to default layout
                    withAnimation(.smooth) {
                        self.selectedDate = nil
                    }
                }) {
                    DayView(day: daysAndDate[1].day, date: daysAndDate[1].date)
                        .background(chosenDay == 0 ? Color.main : Color.optionBtn2)
                        .foregroundColor(chosenDay == 0 ? .white : .letters)
                        .clipShape(Capsule())
                }
                .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
                
                
                VStack {
                    HStack {
                        Button(action: { adjustDate(by: -1) }) { // Previous day btn
                            Image(.backBtn)
                        }
                        Spacer()
                        Text(selectedDate.formatted(date: .abbreviated, time: .omitted)) // Display selected date
                            .font(.subheadline)
                        Spacer()
                        Button(action: { adjustDate(by: 1) }) { // Next day btn
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
                
                Button(action: { // Calendar button
                    isDatePickerPresented = true
                }) {
                    VStack {
                        CalendarIcon()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.optionBtn2)
                    .clipShape(Capsule())
                }
                .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
            } else { // Default layout
                ForEach(daysAndDate.indices, id: \.self) { index in
                    Button(action: {
                        if index == 6 {
                            isDatePickerPresented = true
                        } else {
                            withAnimation {
                                chosenDay = index
                            }
                        }
                    }) {
                        if index == 6 {
                            VStack {
                                CalendarIcon()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            if index == 1{
                                DayView(day: "Tod", date: daysAndDate[index].date)
                                    .foregroundStyle(chosenDay == index ? .white : .letters)
                            } else {
                                DayView(day: daysAndDate[index].day, date: daysAndDate[index].date)
                                    .foregroundColor(chosenDay == index ? .white : .letters)
                            }
                        }
                    }
                    .background(chosenDay == index ? Color.main : Color.optionBtn2)
                    .clipShape(Capsule())
                    .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
                }
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $isDatePickerPresented) {
            VStack {
                withAnimation(.smooth) {
                    DatePicker("Date", selection: Binding<Date>(
                        get: { selectedDate ?? Date() },
                        set: { selectedDate = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                }
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
    
    
    
    // Helper Function to Adjust Date
    private func adjustDate(by days: Int) {
        withAnimation {
            guard let date = selectedDate else { return }
            selectedDate = calendar.date(byAdding: .day, value: days, to: date)
        }
    }
}
