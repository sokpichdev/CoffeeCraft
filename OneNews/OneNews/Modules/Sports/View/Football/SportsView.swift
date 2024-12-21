//
//  SportsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct SportsView: View {
    @StateObject var recommendedVM = RecommendedMatchesViewModel()
    @StateObject var matchVM = MatchesViewModel()
    @StateObject var sDVM = SportDatesViewModel()
    
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if !recommendedVM.recommended.isEmpty {
                            ForEach(recommendedVM.recommended, id: \.id) { recommended in
                                TeamCard(
                                    title: recommended.league?.name ?? "",
                                    leftTeamImage: recommended.homeTeam?.logoPath ?? "",
                                    leftTeamName: recommended.homeTeam?.name ?? "",
                                    leftTeamScore: recommended.homeTeamScore ?? "",
                                    rightTeamImage: recommended.awayTeam?.logoPath ?? "",
                                    rightTeamName: recommended.awayTeam?.name ?? "",
                                    rightTeamScore: recommended.awayTeamScore ?? "",
                                    timer: recommended.timer ?? "",
                                    formattedDateTime: recommended.formattedDateTime ?? "",
                                    isLive: false
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                
                OptionButtons(sportDateVM: sDVM)
                
                HStack(spacing: 4) {
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .live, title: "Live") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .live
                        }
                    }
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .fixtures, title: "Upcoming") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .fixtures
                            sDVM.chosenDay = 0
                        }
                    }
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .results, title: "Finished") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .results
                            sDVM.chosenDay = 5
                        }
                    }
                }
                .cornerRadius(10)
                .padding(4)
                .background(Color.optionBtn2)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 16)

                
                if sDVM.matchType == .fixtures  || sDVM.matchType == .results{
                    DateButtons(sportDatesVM: sDVM)
                }
                
                CustomLabel(text: sDVM.isSelectedFootball ? "Football Matches" : "Basketball Matches")
                    .padding(.horizontal, 16)
                
                
                VStack(spacing: 0) { // Match listings (either fixtures or finished matches)
                    if !matchVM.matches.isEmpty {
                        ForEach(matchVM.matches, id: \.id) { match in
                            SmallLeagueView(
                                leagueTitle: match.name ?? "",
                                leagueImage: match.icon ?? ""
                            )
//                                if sDVM.selectedDate > sDVM.today {
                            if sDVM.matchType == .fixtures {
                                ForEach(match.matches ?? [], id: \.id) { match in
                                    UpcomingMatch(
                                        leftTeamImage: match.homeTeam?.logoPath ?? "",
                                        leftTeamName: match.homeTeam?.name ?? "",
                                        rightTeamImage: match.awayTeam?.logoPath ?? "",
                                        rightTeamName: match.awayTeam?.name ?? "",
                                        schedule: match.displayDateTime ?? ""
                                    )
                                }
                                //                            } else if sDVM.selectedDate < sDVM.today {
                            } else if sDVM.matchType == .results {
                                ForEach(match.matches ?? [], id: \.id) { match in
                                    FinishedMatch(
                                        leftTeamImage: match.homeTeam?.logoPath ?? "",
                                        leftTeamName: match.homeTeam?.name ?? "",
                                        leftTeamScore: match.homeTeamScore ?? "",
                                        rightTeamImage: match.awayTeam?.logoPath ?? "",
                                        rightTeamName: match.awayTeam?.name ?? "",
                                        rightTeamScore: match.awayTeamScore ?? ""
                                    )
                                }
                            } else {
                                ForEach(match.matches ?? [], id: \.id) { match in
                                    LiveMatch(
                                        leftTeamImage: match.homeTeam?.logoPath ?? "",
                                        leftTeamName: match.homeTeam?.name ?? "",
                                        leftTeamScore: match.homeTeamScore ?? "",
                                        rightTeamImage: match.awayTeam?.logoPath ?? "",
                                        rightTeamName: match.awayTeam?.name ?? "",
                                        rightTeamScore: match.awayTeamScore ?? "",
                                        timer: match.timer ?? ""
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text("No matches available.")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .onAppear {
            recommendedVM.fetchRecomendedMatches(sportID: sDVM.isSelectedFootball ? 1 : 2)
            
            matchVM.fetchMatches(sportID: sDVM.isSelectedFootball ? 1 : 2,
                                 date: sDVM.selectedDate.formattedAsDateOnly(),
                                 matchType: sDVM.matchType)
        }
        .onChange(of: sDVM.isSelectedFootball) { _ in
            
            recommendedVM.fetchRecomendedMatches(sportID: sDVM.isSelectedFootball ? 1 : 2)
            matchVM.fetchMatches(sportID: sDVM.isSelectedFootball ? 1 : 2,
                                 date: sDVM.selectedDate.formattedAsDateOnly(),
                                 matchType: sDVM.matchType)
        }
        .onChange(of: sDVM.matchType) { _ in
            matchVM.fetchMatches(sportID: sDVM.isSelectedFootball ? 1 : 2,
                                 date: sDVM.selectedDate.formattedAsDateOnly(),
                                 matchType: sDVM.matchType)
        }
        .onChange(of: sDVM.selectedDate) { _ in
            matchVM.fetchMatches(sportID: sDVM.isSelectedFootball ? 1 : 2,
                                 date: sDVM.selectedDate.formattedAsDateOnly(),
                                 matchType: sDVM.matchType)
        }
        .background(Color.background)
        Spacer()
    }
}
