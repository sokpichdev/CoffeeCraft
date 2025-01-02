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
    @State var isNavigatedToDetail: Bool = false
    @State var isNavigatedToMatches: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                OptionButtons(sportDateVM: sDVM)
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
                
                HStack(spacing: 4) {
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .live, title: "Live") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .live
                        }
                    }
                    .cornerRadius(8)
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .fixtures, title: "Upcoming") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .fixtures
                            sDVM.chosenDay = 0
                        }
                    }
                    .cornerRadius(8)
                    MatchToggleButton(sportDateVM: sDVM, selectedType: .results, title: "Finished") {
                        withAnimation(.easeInOut) {
                            sDVM.matchType = .results
                            sDVM.chosenDay = 5
                        }
                    }
                    .cornerRadius(8)
                }
                .cornerRadius(10)
                .padding(4)
                .background(Color.optionBtn1)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
                
                
                if sDVM.matchType == .fixtures  || sDVM.matchType == .results{
                    DateButtons(sportDatesVM: sDVM)
                }
                
                HStack{
                    CustomLabel(text: sDVM.isSelectedFootball ? "Football Matches" : "Basketball Matches")
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                
                VStack(spacing: 0) { // Match listings (either fixtures or finished matches)
                    if !matchVM.matches.isEmpty {
                        ForEach(matchVM.matches, id: \.id) { league in
                                SmallLeagueView(leagueName: league.name ?? "Unknown League"){
                                    sDVM.leagueID = league.id ?? 0
                                    sDVM.leagueName = league.name ?? ""
                                    sDVM.leagueCountry = league.country ?? ""
                                    isNavigatedToMatches = true
                            }
                            if sDVM.matchType == .fixtures {
                                ForEach(league.matches ?? [], id: \.id) { match in
                                    UpcomingMatch(
                                        leftTeamImage: match.homeTeam?.logoPath ?? "",
                                        leftTeamName: match.homeTeam?.name ?? "",
                                        rightTeamImage: match.awayTeam?.logoPath ?? "",
                                        rightTeamName: match.awayTeam?.name ?? "",
                                        schedule: match.displayDateTime ?? ""
                                    )
                                }
                            } else if sDVM.matchType == .results {
                                ForEach(league.matches ?? [], id: \.id) { match in
                                        FinishedMatch(
                                            matchID: match.id ?? 0,
                                            leftTeamImage: match.homeTeam?.logoPath ?? "",
                                            leftTeamName: match.homeTeam?.name ?? "",
                                            leftTeamScore: match.homeTeamScore ?? "",
                                            rightTeamImage: match.awayTeam?.logoPath ?? "",
                                            rightTeamName: match.awayTeam?.name ?? "",
                                            rightTeamScore: match.awayTeamScore ?? ""
                                        ) {
                                            sDVM.leagueID = league.id ?? 0
                                            sDVM.leagueName = league.name ?? ""
                                            sDVM.leagueCountry = league.country ?? ""
                                            sDVM.matchID = match.id ?? 0
                                            isNavigatedToDetail = true
                                        }
                                }
                            } else {
                                ForEach(league.matches ?? [], id: \.id) { match in
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
                        NoDataView()
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: FMatchDetail().environmentObject(sDVM),
                isActive: $isNavigatedToDetail
            ) { EmptyView() }
        )
        .background(
            NavigationLink(
                destination: FootballMatches(sDVM: sDVM),
                isActive: $isNavigatedToMatches
            ) { EmptyView() }
        )
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
