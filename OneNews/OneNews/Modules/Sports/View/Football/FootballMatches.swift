import SwiftUI

struct FootballMatches: View {
//    @ObservedObject var sDVM: SportDatesViewModel
//    @ObservedObject var matchesVM: MatchesViewModel
    @State var isSelectedFixtures: Bool = true
//    let leagueID: Int
    
    var body: some View {
        VStack(spacing: 10) {
            BigLeagueView(leagueTitle: "Cambodia Premier League", leagueImageName: "cpl")
            
            HStack(spacing: 0) {
                Button (action: {
                    withAnimation(.easeInOut){
                        isSelectedFixtures = true
                    }
                }) {
                    Text("Fixtures")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isSelectedFixtures ? Color.main : Color.optionBtn1)
                        .foregroundColor(isSelectedFixtures ? .white : Color.letters)
                }
                Button (action: {
                    withAnimation(.easeInOut){
                        isSelectedFixtures = false
                    }
                }) {
                    Text("Results")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(!isSelectedFixtures ? Color.main : Color.optionBtn1)
                        .foregroundColor(!isSelectedFixtures ? .white : Color.letters)
                }
            }
            .cornerRadius(10)
            .background(Color.optionBtn1)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 16)
            
            if isSelectedFixtures {
                Text("F")
            } else {
                Text("R")
            }
        }
        .background(Color.background)
        .navigationTitle("Football Matches")
        
        
    }
}
