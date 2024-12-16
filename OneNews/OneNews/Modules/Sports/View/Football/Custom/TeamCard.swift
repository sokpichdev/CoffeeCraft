//
//  TeamCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//


import SwiftUI

struct TeamCard: View {
    @State var title: String = ""
    @State var leftTeamImage: Image = Image(.football)
    @State var leftTeamName: String = ""
    @State var leftTeamScore: Int = 0
    
    @State var rightTeamImage: Image = Image(.basketball)
    @State var rightTeamName: String = ""
    @State var rightTeamScore: Int = 0
    var body: some View {
        
        HStack/*(spacing: 16)*/ {
            ForEach(1...4, id: \.self) { index in
                //                            // Background card
                VStack(spacing: 10) {
                    Spacer(minLength: 0)
                    // section 1
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 0)
                    // section 2
                    HStack {
                        // Left team
                        TeamView(teamImage: leftTeamImage, teamName: leftTeamName)
                            .frame(maxWidth: .infinity, alignment: .center)
//                        Spacer()
                        
                        // Score and Live
                        ZStack {
                            VStack {
                                Text("\(leftTeamScore) - \(rightTeamScore)")
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
                        .frame(width: 65)
//                        Spacer()
                        // Right team
                        TeamView(teamImage: rightTeamImage, teamName: rightTeamName)
                            .frame(maxWidth: .infinity)
                        
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
}
