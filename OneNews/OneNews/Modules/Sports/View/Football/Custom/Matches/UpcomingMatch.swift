//
//  UpcomingMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct UpcomingMatch: View {
    @State var leftTeamImage: String = "football"
    @State var leftTeamName: String = ""
    
    @State var rightTeamImage: String = "basketball"
    @State var rightTeamName: String = ""
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
            }
            Spacer()
                
            HStack {
                TeamView(teamImage: leftTeamImage, teamName: leftTeamName)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                CountDownTimer(countDownTime: 40)
                    .frame(width: 65)
                
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName)
                    .frame(maxWidth: .infinity, alignment: .center)

            }
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
