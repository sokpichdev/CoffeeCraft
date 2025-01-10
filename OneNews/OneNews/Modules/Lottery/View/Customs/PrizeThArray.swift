//
//  PrizeThArray.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

import SwiftUI


struct PrizeThArray: View {
    var prizeTh: String = ""
    var prizeNumber: [String]
    
    var body: some View {
        PrizeView(prizeTh: prizeTh, prizeArray: prizeNumber, prizeString: nil)
    }
}

struct PrizeThString: View {
    var prizeTh: String = ""
    var prizeNumber: String
    
    var body: some View {
        PrizeView(prizeTh: prizeTh, prizeArray: nil, prizeString: prizeNumber)
    }
}


// Base structure for prize display
struct PrizeView: View {
    var prizeTh: String
    var prizeArray: [String]?
    var prizeString: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(prizeTh)
                .fontWeight(.semibold)
                .foregroundStyle(.main)
            
            if let numbers = prizeArray {
                HStack {
                    ForEach(numbers.indices, id: \.self) { index in
                        Text(numbers[index].convertStringToConcatenatedString())
                            .font(.caption)
                            .foregroundStyle(Color.letters)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            else if let number = prizeString {
                Text(number.convertStringToConcatenatedString())
                    .font(.caption)
                    .foregroundStyle(Color.letters)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(10)
    }
}

