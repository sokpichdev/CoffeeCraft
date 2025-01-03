//
//  ResultDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultDetail : View {
    @State var lists: [String] = [] // Changed to 1D array
    @State var isSpecial: Bool = true
    var body: some View {
        VStack {
            ResultDate()
            
            if isSpecial {
                Text("Special Prize").foregroundStyle(.main).fontWeight(.semibold)
            } else {
                Text("")
            }
            
            // Circles in rows
            VStack {
                if lists.count >= 20 {
                    HStack(spacing: -5) {
                        ForEach(lists.prefix(10), id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                    HStack(spacing: -5) {
                        ForEach(lists.suffix(10), id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                } else {
                    HStack(spacing: -5) {
                        ForEach(lists, id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(Color.optionBtn2)
    }
}
