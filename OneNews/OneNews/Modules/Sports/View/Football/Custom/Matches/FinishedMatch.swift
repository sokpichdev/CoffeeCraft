//
//  FinishedMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FinishedMatch: View {
    @State var leftTeamImage: Image = Image(.football)
    @State var leftTeamName: String = ""
    @State var leftTeamScore: Int = 0
    
    @State var rightTeamImage: Image = Image(.basketball)
    @State var rightTeamName: String = ""
    @State var rightTeamScore: Int = 0
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                Text("FT")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.letters.opacity(0.5))
                    
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .frame(height: 20) // Consistent height for top section
//            .background(Color.blue)
            Spacer()
            HStack {
                TeamView(teamImage: leftTeamImage, teamName: leftTeamName)
                    .frame(maxWidth: .infinity, alignment: .center)
                ZStack{
                    ScoreBoardView(leftTeamScore: leftTeamScore, rightTeamScore: rightTeamScore)
                }
                .frame(width: 65)
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName)
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
