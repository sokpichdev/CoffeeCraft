//
//  SportsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct SportsView: View {
    @ObservedObject var viewModel = NewsViewModel()
    let sportOptions = ["Football", "Basketball"]
    @State private var chosenDay: Int? = nil /// track the selected day
    @State private var selectedOptions: Int = 0
    @State private var isDateSelected: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @State private var selectedDate: Date? = nil /// to track the selected date from the date picker
    
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
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    teamCards
                }
                
                optionButtons
                
                CustomLabel(text: "Football Matches")
                    .padding(.horizontal, 16)
                
                dateButtons
                
                sections
            }
            .background(Color.background) // background for all
            Spacer()
        }
        
    }
    
    private var teamCards: some View {
        HStack/*(spacing: 16)*/ {
            ForEach(1...4, id: \.self) { index in
                //                            // Background card
                VStack(spacing: 10) {
                    Spacer(minLength: 0)
                    // section 1
                    HStack {
                        Text("Cambodia U19 vs Vietnam U19")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 0)
                    // section 2
                    HStack {
                        // Left team
                        TeamView(teamImage: Image(.barceTeam), teamName: "North Korea")
                        Spacer()
                        
                        // Score and Live
                        ZStack {
                            VStack {
                                Text("5 - 3")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 65, height: 50)
                            .background(Color.black.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .cornerRadius(10)
                            
                            Image(.live)
                                .resizable()
                                .frame(width: 25, height: 15)
                                .offset(y: -25) // Position "Live" indicator
                        }
                        Spacer()
                        // Right team
                        TeamView(teamImage: Image(.barceTeam), teamName: "South Korea")
                        
                    }.padding(10)
                    
                    Spacer(minLength: 0)
                    VStack{
                        ZStack(alignment: .bottom) {
                            HStack {
                                Text("First Haft 32:44")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("28 Oct, Sat. 03:30 PM")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 40)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .background(Color.black.opacity(0.2))
                        .shadow(radius: 5)
                    }
                    
                }
                .foregroundColor(Color.white)
                .frame(width: 330, height: 170)
                .background(LinearGradient(gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]), startPoint: .top, endPoint: .bottom))
                
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }
        .padding(.horizontal, 16) // avoid padding the scrollView
    }
    
    private var optionButtons: some View {
        HStack { // buttons
            ForEach(sportOptions.indices, id: \.self) { index in
                CustomOptionButtons (title: sportOptions[index],
                                     imageName: sportOptions[index],
                                     isSelected: selectedOptions == index) {
                    selectedOptions = index
                }
            }
            Spacer() /// push button to the left
            
        }
        .padding(16)
    }
    
    private var dateButtons: some View {
        HStack(spacing: 10) {
            if let selectedDate = selectedDate {
                // Button to reset to default layout
                Button(action: {
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
                        // Previous day button
                        Button(action: { adjustDate(by: -1) }) {
                            Image(.backBtn)
                        }
                        Spacer()
                        // Display selected date
                        Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                        Spacer()
                        // Next day button
                        Button(action: { adjustDate(by: 1) }) {
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
                
                // Calendar button
                Button(action: {
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
            } else {
                // Default layout
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
                            DayView(day: daysAndDate[index].day, date: daysAndDate[index].date)
                                .foregroundColor(chosenDay == index ? .white : .letters)
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
    
    
    private var sections: some View {
        ForEach(1...3, id: \.self){ _ in
            // section
            SmallLeagueView(leagueTitle: "Cambodia Premier Leaque", leagueImageName: "cpl")
            
            
            Button(action: {
                
            }) {
                NavigationLink(destination: FMatchDetail()) {
                    LiveMatch()
                }
            }.foregroundStyle(Color.black)
            
            Button(action: {
                
            }) {
                NavigationLink(destination: FMatchDetail()) {
                    UpcomingMatch()
                }
            }.foregroundStyle(Color.black)
            
            Button(action: {
                
            }) {
                NavigationLink(destination: FMatchDetail()) {
                    FinishedMatch()
                }
            }.foregroundStyle(Color.black)
            
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

#Preview {
    SportsView()
}
