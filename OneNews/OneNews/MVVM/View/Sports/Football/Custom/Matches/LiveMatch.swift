//
//  LiveMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct LiveMatch: View {
    @State var leftTeamImage: Image = Image(.football)
    @State var leftTeamName: String = ""
    @State var leftTeamScore: Int = 0
    
    @State var rightTeamImage: Image = Image(.basketball)
    @State var rightTeamName: String = ""
    @State var rightTeamScore: Int = 0
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
                TeamView(teamImage: leftTeamImage, teamName: leftTeamName) /// Left team
                    .frame(maxWidth: .infinity, alignment: .center)
                ZStack { /// Score and Live
                    ScoreBoardView(leftTeamScore: leftTeamScore, rightTeamScore: rightTeamScore)
                    
                    Image(.live) /// Live indicator
                        .resizable()
                        .frame(width: 25, height: 15)
                        .offset(y: -40) /// Position "Live" indicator
                }
                .frame(width: 65)
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName) /// Right team
                    .frame(maxWidth: .infinity, alignment: .center)

            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.optionBtn2.opacity(1.5),.optionBtn2.opacity(0.5), .optionBtn2.opacity(1.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )

        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

#Preview {
    LiveMatch()
}
