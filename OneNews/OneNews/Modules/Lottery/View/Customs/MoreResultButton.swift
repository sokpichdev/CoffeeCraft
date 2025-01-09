//
//  MoreResultButton.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct MoreResultButton: View {
    var body: some View {
        NavigationLink(destination: MoreResultsView()) {
            Text("MORE RESULTS")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.main, lineWidth: 1))
        .cornerRadius(25)
        .foregroundStyle(.letters)
        .padding(.bottom, 16)
    }
}
