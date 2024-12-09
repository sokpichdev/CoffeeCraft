//
//  LiveMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct LiveMatch: View {
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 0) {
                Spacer()/// Matches
    //            TimerView(time: 68)
                Text("\(34)'")
                    .font(.system(size: 12, weight: .regular))
                
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 20, maxWidth: 20)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .frame(height: 20)  //Consistent height for top section
            .foregroundStyle(.red)
            
            Spacer()
            HStack {
                TeamView(teamImage: Image(.barceTeam), teamName: "North Korea") /// Left team
                Spacer()
                ZStack { /// Score and Live
                    ScoreBoardView(leftTeamScore: 3, rightTeamScore: 1)
                    
                    Image(.live) /// Live indicator
                        .resizable()
                        .frame(width: 25, height: 15)
                        .offset(y: -40) /// Position "Live" indicator
                }
                
                Spacer()
                TeamView(teamImage: Image(.barceTeam), teamName: "South Korea") /// Right team
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

#Preview {
    LiveMatch()
}
