//
//  FinishedMatch.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FinishedMatch: View {
    var leftTeamImage: String = "football"
    var leftTeamName: String = ""
    var leftTeamScore: String = "0"
    
    var rightTeamImage: String = "basketball"
    var rightTeamName: String = ""
    var rightTeamScore: String = "0"
    
    @ObservedObject var sDVM: SportDatesViewModel
    @State private var selectedSummary: Bool = true
    
    var body: some View {
        NavigationLink(destination: FMatchDetail(selectedSummary: $selectedSummary, sDVM: sDVM)) {
            VStack(spacing: 5) {
                HStack {
                    Spacer()
                    Text("FT")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.letters.opacity(0.5))
                        
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                .frame(height: 20)
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
    
}
