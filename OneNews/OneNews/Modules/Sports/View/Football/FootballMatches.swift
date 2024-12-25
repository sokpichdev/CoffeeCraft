import SwiftUI

struct FootballMatches: View {
    @StateObject var leagueVM = LeagueViewModel()
    @ObservedObject var sDVM = SportDatesViewModel()
    @State var isSelectedFixtures: Bool = true
    var leagueID: Int
    var leagueName: String
    var leagueCountry: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                BigLeagueView(leagueTitle: leagueName, leagueCountry: leagueCountry)
                
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
                
//                if !leagueVM.matches.isEmpty {
//                    
//                        if isSelectedFixtures {
////                            ForEach(leagueVM.matches, id: \.id) { match in
////                                UpcomingMatch(
////                                    leftTeamImage: match.homeTeam?.logoPath ?? "",
////                                    leftTeamName: match.homeTeam?.name ?? "",
////                                    rightTeamImage: match.awayTeam?.logoPath ?? "",
////                                    rightTeamName: match.awayTeam?.name ?? "",
////                                    schedule: match.displayDateTime ?? ""
////                                )
////                            }
//                        } else {
////                            ForEach(leagueVM.matches, id: \.id) { match in
////                                FinishedMatch(
////                                    leftTeamImage: match.homeTeam?.logoPath ?? "",
////                                    leftTeamName: match.homeTeam?.name ?? "",
////                                    leftTeamScore: match.homeTeamScore ?? "",
////                                    rightTeamImage: match.awayTeam?.logoPath ?? "",
////                                    rightTeamName: match.awayTeam?.name ?? "",
////                                    rightTeamScore: match.awayTeamScore ?? ""
////                                )
////                            }
//                        }
//                } else {
//                    NoDataView()
//                }
            }
            
            .onAppear {
                leagueVM.fetchLeagueMatches(sportID: sDVM.isSelectedFootball ? 1 : 2, leagueID: leagueID, matchType: .fixtures)
            }
            .onChange(of: isSelectedFixtures) { _ in
                leagueVM.fetchLeagueMatches(sportID: sDVM.isSelectedFootball ? 1 : 2, leagueID: leagueID, matchType: isSelectedFixtures ? .fixtures :  .results)
            }
            .navigationTitle("Football Matches")
        }
        .background(Color.background)
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
