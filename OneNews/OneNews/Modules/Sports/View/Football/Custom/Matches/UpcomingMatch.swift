//
//  UpcomingMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct UpcomingMatch: View {
    var leftTeamImage: String = ""
    var leftTeamName: String = ""
    
    var rightTeamImage: String = ""
    var rightTeamName: String = ""
    var schedule: String = "00:00:00"
    
    
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
                
                CountDownTimer(countDownTime: schedule)
                    .frame(width: 65)
                
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName)
                    .frame(maxWidth: .infinity, alignment: .center)

            }
            Spacer()
        }
        .padding(16)
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
