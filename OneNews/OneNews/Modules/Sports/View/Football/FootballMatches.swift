import SwiftUI

struct FootballMatches: View {
    @State private var selectedFixtures: Bool = true
    
    var body: some View {
        VStack(spacing: 10) {
            BigLeagueView(leagueTitle: "Cambodia Premier League", leagueImageName: "cpl")
            
            HStack(spacing: 0) {
                MatchToggleButton(title: "Fixtures", isSelected: selectedFixtures) {
                    withAnimation(.easeInOut){
                        selectedFixtures = true
                    }
                }
                MatchToggleButton(title: "Results", isSelected: !selectedFixtures) {
                    withAnimation(.easeInOut){
                        selectedFixtures = false
                    }
                }
            }
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .shadow(radius: 5)
            
            ScrollView {
                if selectedFixtures {
                    ForEach(1...4, id: \.self) { _ in
                        Button(action: {
                            
                        }) {
                            NavigationLink(destination: FMatchDetail()) {
                                UpcomingMatch(leftTeamImage: Image(.barceTeam), leftTeamName: "Japan", rightTeamImage: Image(.barceTeam), rightTeamName: "China")
                            }
                        }.foregroundStyle(Color.letters)
                    }
                } else {
                    ForEach(1...5, id: \.self) { _ in
                        Button(action: {
                            
                        }) {
                            NavigationLink(destination: FMatchDetail()) {
                                FinishedMatch(leftTeamImage: Image(.barceTeam), leftTeamName: "Thailand", leftTeamScore: 1, rightTeamImage: Image(.barceTeam), rightTeamName: "Cambodia", rightTeamScore: 3)
                            }
                        }.foregroundStyle(Color.letters)
                    }
                }
            }
            
        }
        .background(Color.background)
        .navigationTitle("Football Matches")
        
        
    }
}


#Preview {
    FootballMatches()
}
//ForEach(1...3, id: \.self){ _ in
