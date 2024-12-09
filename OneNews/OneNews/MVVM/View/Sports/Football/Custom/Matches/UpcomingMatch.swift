//
//  UpcomingMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct UpcomingMatch: View {
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
                TeamView(teamImage: Image(.barceTeam), teamName: "North Korea")
                Spacer()
                
                CountDownTimer(countDownTime: 40)
                Spacer()
                
                TeamView(teamImage: Image(.barceTeam), teamName: "South Korea")
            }
            .padding(.horizontal, 16)
            Spacer()
        }
//        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: 120)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
   
}

#Preview {
    UpcomingMatch()
}
