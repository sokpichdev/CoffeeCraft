//
//  LeagueView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct SmallLeagueView: View {
    //    @StateObject var matchVM = MatchesViewModel()
    var leagueName: String
    var leagueID: Int
    var leagueCountry: String
    
    var body: some View {
        
        NavigationLink(destination: FootballMatches(leagueID: leagueID, leagueName: leagueName, leagueCountry: leagueCountry)) {
            HStack {
                Text(leagueName)
                    .foregroundStyle(.white)
                
                Spacer()
                Image(.star2)
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
    var leagueTitle: String
    var leagueCountry: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(leagueTitle)
                    .foregroundStyle(.white)
                Text(leagueCountry)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            Spacer()
            Image(.star2)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
            
        }
        //        .frame(width: .infinity, height: .infinity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 10, leading: 16,bottom: 10, trailing: 16))
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}
