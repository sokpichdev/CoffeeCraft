//
//  ScoreBoardView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct ScoreBoardView: View {
    @State var leftTeamScore: String = "0"
    @State var rightTeamScore: String = "0"
    
    var body: some View {
        VStack {
            Text("\(leftTeamScore) - \(rightTeamScore)")
                .foregroundColor(.letters)
        }
        .frame(width: 65, height: 50)
        .background(Color.letters.opacity(0.1)) /// Background color for the box
        .cornerRadius(10)
        .shadow( radius: 10, x: 0, y: 4) /// directly to the VStack holding the score (5 - 3).
        .offset(y: -15)
    }
    
}
