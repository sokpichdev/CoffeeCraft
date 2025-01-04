//
//  SectionResult.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct SectionResult: View {
//    @State var imageName: Image = Image(.result)
    var iconName: String
    var title: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20, alignment: .leading)
            
            CustomLabel(text: title, textColor: .white, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkPurple, Color.lightPurple]), startPoint: .leading, endPoint: .trailing))
    }
}
