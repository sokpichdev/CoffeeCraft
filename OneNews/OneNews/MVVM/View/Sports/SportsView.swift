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
    let days = ["Sat", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State var chosenDay: Int? = nil // track the selected day
    @State var selectedOptions: Int = 0
    @State var isDateSelected: Bool = false
    
    @State private var isDatePickerPresented: Bool = false
    @State private var selectedDate: Date? = nil // to track the selected date from the date picker
    
    var body: some View {
        ScrollView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
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
                                        .shadow(radius: 5)
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
                                //                                .padding(.bottom, -17) // teanh vea oy smer ng bottom. but not dynamic
                                
                            }
                            .foregroundColor(Color.white)
                            //                                        .padding()
                            .frame(width: 330, height: 170)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]), startPoint: .top, endPoint: .bottom))
                            
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            //
                        }
                        //
                    }
                    .padding(.horizontal, 16) // avoid padding the scrollView
                }
                
                HStack { // buttons
                    ForEach(sportOptions.indices, id: \.self) { index in
                        CustomOptionButtons (title: sportOptions[index],
                                             imageName: sportOptions[index],
                                             isSelected: selectedOptions == index) {
                            selectedOptions = index
                        }
                    }
                    Spacer() // push button to the left
                    
                }
                .padding(16)
                
                CustomLabel(text: "Football Matches")
                    .padding(.horizontal, 16)
                
                // Date buttons
                HStack(spacing: 10) {
                    // Conditional layout
                    if let selectedDate = selectedDate {
                        // Display one button on the left
                        Button(action: {
//                            chosenDay = 0 // Optionally reset or reassign
                            withAnimation(.smooth){
                                self.selectedDate = nil // Reset the selectedDate to nil to go back to default layout
                            }

                        }) {
                            VStack {
                                Text(days[0])
                                    .font(.system(size: 9, weight: .regular))
                                    .frame(width: 20, height: 12)
                                Text("10")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(chosenDay == 0 ? Color.main : Color.white)
                            .foregroundColor(chosenDay == 0 ? .white : .black)
                            .clipShape(Capsule())
                        }
                        .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
                        
                        // Display the selected date as a single button spanning 5 spaces
                        Button(action: {
                            print("Selected Date: \(selectedDate)")
                        }) {
                            VStack {
                                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.main)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .frame(width: ((UIScreen.main.bounds.size.width - 60 - 32) / 7) * 6, height: 65)
                        
                        // Calendar button
                        Button(action: {
                            isDatePickerPresented = true
                        }) {
                            VStack {
                                CalendarIcon()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .clipShape(Capsule())
                        }
                        .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
                    } else {
                        // Default layout
                        ForEach(days.indices, id: \.self) { index in
                            Button(action: {
                                if index == 6 {
                                    isDatePickerPresented = true // Show date picker for the last button
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
                                    VStack {
                                        Text(days[index])
                                            .font(.system(size: 9, weight: .regular))
                                            .frame(width: 20, height: 12)
                                        Text("\(10 + index)")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundColor(chosenDay == index ? .white : .black)
                                    
                                }
                            }
                            .background(chosenDay == index ? Color.main : Color.white)
                            .clipShape(Capsule())
                            .frame(width: (UIScreen.main.bounds.size.width - 60 - 32) / 7, height: 65)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .sheet(isPresented: $isDatePickerPresented) {
                    VStack {
                        withAnimation(.smooth){
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
                
                
                ForEach(1...4, id: \.self){ _ in
                    // section
                    HStack(spacing: 16) {
                        Image(.cpl)
                        Text("Cambodia Premier Leaque")
                            .foregroundStyle(.white)
                        
                        Spacer()
                        Image(.star2)
                        
                        Image(.frontBtn)
                    }
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 10)
                    .padding(EdgeInsets(top: 10, leading: 16,bottom: 10, trailing: 16))
                    .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    
                    ForEach(1...5, id: \.self) { _ in
                        // Matches
                        VStack(spacing: 5) {
                            HStack {
                                Spacer()
                                Text("68'")
                                Image(systemName: "timer")
                            }
                            .foregroundStyle(.red)
                            HStack {
                                // Left team
                                TeamView(teamImage: Image(.barceTeam), teamName: "North Korea")
                                
                                Spacer()
                                
                                // Score and Live
                                ZStack {
                                    // Score box with shadow
                                    VStack {
                                        Text("5 - 3")
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 65, height: 50)
                                    .background(Color.white) // Background color for the box
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // directly to the VStack holding the score (5 - 3).
                                    .offset(y: -15)
                                    // Live indicator
                                    Image(.live)
                                        .resizable()
                                        .frame(width: 25, height: 15)
                                        .offset(y: -40) // Position "Live" indicator
                                }
                                
                                Spacer()
                                // Right team
                                TeamView(teamImage: Image(.barceTeam), teamName: "South korea")
                            }
                            
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.systemGray5)) // background for all
            Spacer()
        }
    }
    
}

#Preview {
    SportsView()
}
