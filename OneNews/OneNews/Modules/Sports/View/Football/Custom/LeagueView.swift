//
//  LeagueView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct SmallLeagueView: View {
//    @ObservedObject var sdVM: SportDatesViewModel
//    @ObservedObject var matchVM: MatchesViewModel
    var leagueName: String = ""
    var leagueIcon: String = ""
    
//    var onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(leagueIcon)
            Text(leagueName)
                .foregroundStyle(.white)
            
            Spacer()
            Image(.star2)
            
            NavigationLink(destination: FootballMatches()) {
                Image(.frontBtn)
            }

        }
        .padding(EdgeInsets(top: 10, leading: 16,bottom: 10, trailing: 16))
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
}


struct BigLeagueView: View {
    @State var leagueTitle: String = ""
    @State var leagueImageName: String = ""
    
    var body: some View {
        HStack(spacing: 16) {
            Image(leagueImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
            VStack(alignment: .leading){
                Text(leagueTitle)
                    .foregroundStyle(.white)
                Text("Cambodia")
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            
            Spacer()
            Image(.star2)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
            
        }
        .frame(width: .infinity, height: 60)
        .padding(EdgeInsets(top: 10, leading: 16,bottom: 10, trailing: 16))
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}
