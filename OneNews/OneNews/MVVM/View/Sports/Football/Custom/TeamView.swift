//
//  TeamView.swift
//  OneNews
//
//  Created by Sok Pich on 12/6/24.
//

import SwiftUI

struct TeamView: View {
    let teamImage: Image
    let teamName: String
    let imageSize: CGSize = CGSize(width: 20, height: 20)

    var body: some View {
        VStack {
            teamImage
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.width, height: imageSize.height)
            Text(teamName)
        }
        .foregroundStyle(.letters)
    }
}
