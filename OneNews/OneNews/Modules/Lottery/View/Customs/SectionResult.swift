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
            LoadImages(image: iconName, maxWidth: 20, maxHeight: 20)
            CustomLabel(text: title, textColor: .white, alignment: .center)
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(LinearGradient(gradient: Gradient(colors: [Color.darkPurple, Color.lightPurple]), startPoint: .leading, endPoint: .trailing))
    }
}
