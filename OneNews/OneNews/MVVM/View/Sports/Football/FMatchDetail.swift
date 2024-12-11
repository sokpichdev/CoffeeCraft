//
//  FMatchDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FMatchDetail: View {
    @State var selectedSummary: Bool = true
    var body: some View {
        ScrollView {
        VStack(spacing: 10) {
            BigLeagueView(leagueTitle: "Cambodia Premier League", leagueImageName: "cpl")
            
            FinishedMatch()
            
            HStack(spacing: 0) {
                MatchToggleButton(title: "Summary", isSelected: selectedSummary) {
                    withAnimation(.easeInOut){
                        selectedSummary = true
                    }
                }
                MatchToggleButton(title: "Stats", isSelected: !selectedSummary) {
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

#Preview {
    FMatchDetail()
}
