//
//  CustomLabel.swift
//  OneNews
//
//  Created by Sok Pich on 12/6/24.
//

import SwiftUI

struct CustomLabel: View {
    var text: String
    var font: Font = .title3
    var fontWeight: Font.Weight = .bold
    var textColor: Color = .primary // Default system color
    var alignment: Alignment = .leading // Default alignment
    
    var body: some View {
        HStack {
            Text(text)
                .font(font)
                .fontWeight(fontWeight)
                .foregroundColor(textColor)
//            if alignment == .leading {
//                Text(text)
//                    .font(font)
//                    .fontWeight(fontWeight)
//                    .foregroundColor(textColor)
////                Spacer()
//            } else if alignment == .trailing {
////                Spacer()
//                Text(text)
//                    .font(font)
//                    .fontWeight(fontWeight)
//                    .foregroundColor(textColor)
//                    .multilineTextAlignment(.)
//            } else {
//                Spacer()
//                Text(text)
//                    .font(font)
//                    .fontWeight(fontWeight)
//                    .foregroundColor(textColor)
//                Spacer()
//            }
                
        }
//        .frame(maxWidth: .infinity)
    }
}
// example uses
/*
    -----  Default Styling -----
    Ex1: CustomLabel(text: "Latest News")

 
    ----- Custom Styling -------
    Ex2: CustomLabel(
             text: "Breaking Updates",
             font: .headline,
             fontWeight: .semibold,
             textColor: .blue
        )

    -----  Center-Aligned ------
    Ex3: CustomLabel(
            text: "Centered Title",
            alignment: .center
        )

*/
