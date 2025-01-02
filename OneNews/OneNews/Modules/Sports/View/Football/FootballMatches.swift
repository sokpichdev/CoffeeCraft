import SwiftUI

struct FootballMatches: View {
    @StateObject var leagueVM = LeagueViewModel()
    @ObservedObject var sDVM = SportDatesViewModel()
    @State private var isSelectedFixtures: Bool = true
    @State private var navigatedToDetail: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            CustomNavigation(title: sDVM.isSelectedFootball ? "Football Matches" : "Basketball Matches")
            ScrollView {
                VStack(spacing: 10) {
                    BigLeagueView(leagueName: sDVM.leagueName, leagueCountry: sDVM.leagueCountry)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSelectedFixtures = true
                            }
                        }) {
                            buttonTitle("Fixtures")
                        }
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSelectedFixtures = false
                            }
                        }) {
                            buttonTitle("Results")
                        }
                    }
                    .cornerRadius(10)
                    .background(Color.optionBtn1)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 16)
                    
                    if !leagueVM.matchList.isEmpty {
                        ForEach(leagueVM.matchList, id: \.id) { match in
                            if isSelectedFixtures {
                                UpcomingMatch(
                                    leftTeamImage: match.homeTeam?.logoPath ?? "",
                                    leftTeamName: match.homeTeam?.name ?? "",
                                    rightTeamImage: match.awayTeam?.logoPath ?? "",
                                    rightTeamName: match.awayTeam?.name ?? "",
                                    schedule: match.displayDateTime ?? ""
                                )
                            } else {
                                FinishedMatch(
                                    matchID: match.id ?? 0,
                                    leftTeamImage: match.homeTeam?.logoPath ?? "",
                                    leftTeamName: match.homeTeam?.name ?? "",
                                    leftTeamScore: match.homeTeamScore ?? "",
                                    rightTeamImage: match.awayTeam?.logoPath ?? "",
                                    rightTeamName: match.awayTeam?.name ?? "",
                                    rightTeamScore: match.awayTeamScore ?? ""
                                ) {
                                    navigatedToDetail = true
                                    sDVM.leagueID = match.leagueID ?? 0
                                }
                            }
                        }
                    } else {
                        NoDataView()
                    }
                }
                
                
                .padding(.vertical, 16)
            }
            .onAppear {
                leagueVM.fetchLeagueMatches(sportID: sDVM.isSelectedFootball ? 1 : 2, leagueID: sDVM.leagueID, matchType: .fixtures)
            }
            .onChange(of: isSelectedFixtures) { _ in
                leagueVM.fetchLeagueMatches(sportID: sDVM.isSelectedFootball ? 1 : 2, leagueID: sDVM.leagueID, matchType: isSelectedFixtures ? .fixtures :  .results)
            }
            .background(Color.background)
            .background(
                NavigationLink("",
                               destination: FMatchDetail(sDVM: sDVM),
                               isActive: $navigatedToDetail)
            )
        }
    }
    private func buttonTitle(_ title: String) -> some View {
        let isSelected = (title == "Fixtures" && isSelectedFixtures) || (title == "Results" && !isSelectedFixtures)
        return Text(title)
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? Color.main : Color.optionBtn1)
            .foregroundColor(isSelected ? .white : Color.letters)
    }
}
