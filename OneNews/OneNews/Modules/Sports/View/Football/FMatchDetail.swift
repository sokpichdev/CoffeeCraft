//
//  FMatchDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct FMatchDetail: View {
    @State private var selectedSummary: Bool = true
    @ObservedObject var sDVM: SportDatesViewModel
    @StateObject private var mDVM = MatchDetailViewModel()
//    var matchID: Int
    var body: some View {
        VStack(spacing: 0){
            CustomNavigation(title: "Match Detail")
            ScrollView {
                VStack(spacing: 10) {
                    BigLeagueView(leagueName: sDVM.leagueName, leagueCountry: sDVM.leagueCountry)
                    
                    FinishedMatch(matchID: sDVM.matchID,
                                  leftTeamImage: mDVM.mDVM.homeTeam?.logoPath ?? "",
                                  leftTeamName: mDVM.mDVM.homeTeam?.name ?? "",
                                  leftTeamScore: mDVM.mDVM.homeTeamScore ?? "",
                                  rightTeamImage: mDVM.mDVM.awayTeam?.logoPath ?? "",
                                  rightTeamName: mDVM.mDVM.awayTeam?.name ?? "",
                                  rightTeamScore: mDVM.mDVM.awayTeamScore ?? "")
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedSummary = true
                            }
                        }) {
                            buttonTitle("Summary")
                        }
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedSummary = false
                            }
                        }) {
                            buttonTitle("Stats")
                        }
                    }
                    .cornerRadius(10)
                    .background(Color.optionBtn1)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 16)
                    
                    if selectedSummary {
                        SummaryView(mDVM: mDVM)
                    } else {
                        StatsView(mDVM: mDVM)
                    }
                }
            }
            .background(Color.background)
        }
        .onAppear() {
            mDVM.fetchMatchDetail(sportID: sDVM.isSelectedFootball ? 1 : 2, leagueID: sDVM.leagueID, matchID: sDVM.matchID)
            print("league ID: \(sDVM.leagueID) - match ID: \(sDVM.matchID)")
        }
    }
    private func buttonTitle(_ title: String) -> some View {
        let isSelected = (title == "Summary" && selectedSummary) || (title == "Stats" && !selectedSummary)
        return Text(title)
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? Color.main : Color.optionBtn1)
            .foregroundColor(isSelected ? .white : Color.letters)
    }
}
