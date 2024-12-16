//
//  PrizeTh.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI
struct PrizeTh: View {
    
    @State var prizeTh: String = ""
    @State var prizeNumber: [Int] = []
    
    var body: some View {
        VStack(alignment: .center){
            Text(prizeTh)
                .fontWeight(.bold)
                .foregroundStyle(.main)
            
            HStack {
                ForEach(prizeNumber.indices, id: \.self){ index in
                    Text("\(prizeNumber[index])")
                        .font(.caption)
                        .foregroundStyle(Color.letters)
                        
                }
                
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
}

