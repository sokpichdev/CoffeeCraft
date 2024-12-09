//
//  FinishedMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FinishedMatch: View {
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                Text("FT")
                    .font(.system(size: 12, weight: .regular))
                    
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .frame(height: 20) // Consistent height for top section
//            .background(Color.blue)
            Spacer()
            HStack {
                TeamView(teamImage: Image(.barceTeam), teamName: "North Korea")
                Spacer()
                ZStack{
                    ScoreBoardView(leftTeamScore: 3, rightTeamScore: 1)
                }
                Spacer()
                TeamView(teamImage: Image(.barceTeam), teamName: "South Korea")
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
