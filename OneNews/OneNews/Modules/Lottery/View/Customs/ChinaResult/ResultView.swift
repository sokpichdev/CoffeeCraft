//
//  ResultView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct ResultView: View {
    @State var lists: [Int] = [] // Changed to 1D array
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionResult()
            
            ResultDetail(lists: [12, 1, 6, 33, 76, 19, 23, 23, 54, 22].shuffled(), isSpecial: false)
            
            Spacer()
            MoreResultButton()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
        
    }
}


#Preview {
    ResultView()
}

