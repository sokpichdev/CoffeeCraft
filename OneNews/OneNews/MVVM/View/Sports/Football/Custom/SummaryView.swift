//
//  SummaryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/10/24.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(1...3, id: \.self) {_ in
                SummaryDetail(minutes: "", description: "Goal kick for Leeds United.")
                Divider()
                
                SummaryDetail(minutes: "90' + 13'", description: "Wolverhampton player Pablo Sarabia strikes the shot off target, ball is cleared by the Leeds United.")
                Divider()
            }
        }
        .background(Color.optionBtn1)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.letters.opacity(0.2), lineWidth: 3))
        .cornerRadius(10)
        .padding(10)
        .background(Color.optionBtn1)
        .cornerRadius(10)
        .padding(16)
    }
    
}


struct SummaryDetail: View {
    var minutes: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top) { // for better handling of multiline text
            Text(minutes.isEmpty ? " " : minutes) // Placeholder for empty minutes
                .frame(maxWidth: 70, alignment: .center)
                .foregroundColor(.letters)
                .multilineTextAlignment(.center)
            
            Text(description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .background(Color.optionBtn1)
        }
        .font(.caption2)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
