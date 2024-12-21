//
//  FMatchDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FMatchDetail: View {
    @State var selectedSummary: Bool = true
    @StateObject var sDVM: SportDatesViewModel
    var body: some View {
        ScrollView {
        VStack(spacing: 10) {
            BigLeagueView(leagueTitle: "Cambodia Premier League", leagueImageName: "cpl")
            
            FinishedMatch(leftTeamImage: "football", leftTeamName: "Thailand", leftTeamScore: "1", rightTeamImage: "basketball", rightTeamName: "Cambodia", rightTeamScore: "3")
            
            HStack(spacing: 0) {
                MatchToggleButton(sportDateVM: sDVM, selectedType: sDVM.matchType, title: "Summary") {
                    withAnimation(.easeInOut){
                        selectedSummary = true
                    }
                }
                MatchToggleButton(sportDateVM: sDVM, selectedType: sDVM.matchType, title: "Stats") {
                    withAnimation(.easeInOut){
                        selectedSummary = false
                    }
                }
            }
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .shadow(radius: 5)
            
                if selectedSummary {
                    SummaryView()
                } else {
                    StatsView()
                }
            
//            Spacer()
        }
            .background(Color.background)
    }
    }
}
