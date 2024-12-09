//
//  ScoreBoardView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct ScoreBoardView: View {
    @State var leftTeamScore: Int = 0
    @State var rightTeamScore: Int = 0
    
    var body: some View {
        VStack {
            Text("\(leftTeamScore) - \(rightTeamScore)")
                .foregroundColor(.black)
        }
        .frame(width: 65, height: 50)
        .background(Color.white) /// Background color for the box
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) /// directly to the VStack holding the score (5 - 3).
        .offset(y: -15)
    }
    
}
