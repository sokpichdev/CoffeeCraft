//
//  TeamView.swift
//  OneNews
//
//  Created by Sok Pich on 12/6/24.
//

import SwiftUI

struct TeamView: View {
    let teamImage: String
    let teamName: String
    let maxWidth: CGFloat = 25
    let maxHeight: CGFloat = 25
    

    var body: some View {
        VStack {
            LoadImages(image: teamImage, maxWidth: maxWidth, maxHeight: maxHeight, isFit: false, shadow: 0)
            Text(teamName)
                .font(.subheadline)
        }
        .foregroundStyle(.letters)
    }
}
