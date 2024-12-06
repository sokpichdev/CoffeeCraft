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
    @State var chosenDay = 3
    @State var selectedOptions: Int = 0
    
    var body: some View {
        ScrollView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack/*(spacing: 16)*/ {
                        ForEach(1...4, id: \.self) { index in
//                            // Background card
                            VStack(spacing: 10) {
                                // section 1
                                HStack {
                                    Text("Cambodia U19 vs Vietnam U19")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                                }
                                .padding(.horizontal, 16)
                                
                                
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
                                }.padding(.bottom, -17) // teanh vea oy smer ng bottom.
                                
//                                .cornerRadius(15, corners: [.bottomLeft, .bottomRight]) // Apply rounded corners to bottom only

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
                
                
                HStack { // button dates.
                    ForEach(days.indices, id: \.self) { index in
                        Button(action: {
                            chosenDay = index
                        }) {
                            VStack {
                                Text(days[index]) // Day name
                                   .font(.system(size: 9, weight: .regular)) // Small, legible font
                                   .frame(width: 20, height: 12) // Slightly larger for visibility
                               
                               Text("\(10 + index)") // Date number
                                   .font(.system(size: 12, weight: .semibold)) // Slightly bolder
                            }
//                            .frame(width: .infinity, height: 80)
                            .frame(width: 14.5, height: 65)
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }
                    }
                }
//                .background(Color.green)
                
                
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.blue)
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
