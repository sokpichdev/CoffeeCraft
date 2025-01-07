//
//  PrizeThArray.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct PrizeThArray: View {
    
    var prizeTh: String = ""
    var prizeNumber: [String]
    
    var body: some View {
        VStack(alignment: .center){
            Text(prizeTh)
                .fontWeight(.semibold)
                .foregroundStyle(.main)
            
            HStack {
                ForEach(prizeNumber.indices, id: \.self){ index in
                    Text(prizeNumber[index].convertStringToConcatenatedString())
                        .font(.caption)
                        .foregroundStyle(Color.letters)
                        
                }
                
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(10)
    }
}
