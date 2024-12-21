import SwiftUI

struct FootballMatches: View {
    @ObservedObject var sDVM: SportDatesViewModel
    var body: some View {
        VStack(spacing: 10) {
            BigLeagueView(leagueTitle: "Cambodia Premier League", leagueImageName: "cpl")
            
            HStack(spacing: 0) {
                MatchToggleButton(sportDateVM: sDVM, selectedType: sDVM.matchType, title: "Fixtures") {
                    withAnimation(.easeInOut){
                        sDVM.matchType = .fixtures
                    }
                }
                MatchToggleButton(sportDateVM: sDVM, selectedType: sDVM.matchType, title: "Results") {
                    withAnimation(.easeInOut){
                        sDVM.matchType = .results
                    }
                }
            }
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .shadow(radius: 5)
            
//            ScrollView {
//                if selectedFixtures {
//                    ForEach(1...4, id: \.self) { _ in
//                        Button(action: {
//                            
//                        }) {
//                            NavigationLink(destination: FMatchDetail()) {
//                                UpcomingMatch(leftTeamImage: "barceTeam", leftTeamName: "Japan", rightTeamImage: "barceTeam", rightTeamName: "China")
//                            }
//                        }.foregroundStyle(Color.letters)
//                    }
//                } else {
//                    ForEach(1...5, id: \.self) { _ in
//                        Button(action: {
//                            
//                        }) {
//                            NavigationLink(destination: FMatchDetail()) {
//                                FinishedMatch(leftTeamImage: "barceTeam", leftTeamName: "Thailand", leftTeamScore: "1", rightTeamImage: "barceTeam", rightTeamName: "Cambodia", rightTeamScore: "3")
//                            }
//                        }.foregroundStyle(Color.letters)
//                    }
//                }
//            }
            
        }
        .background(Color.background)
        .navigationTitle("Football Matches")
        
        
    }
}
