//
//  NoDataView.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
        VStack{
            Image(.noData)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipped()
            Text("No Data")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.letters.opacity(0.5))
        }
    }
}
