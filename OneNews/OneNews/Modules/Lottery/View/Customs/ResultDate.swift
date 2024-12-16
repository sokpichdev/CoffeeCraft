//
//  ResultDate.swift
//  OneNews
//
//  Created by Sok Pich on 12/14/24.
//

import SwiftUI

struct ResultDate: View {
    var body: some View {
        Text("DRAW ID - 56213")
            .font(.caption)
        
        HStack {
            Text("THURSDAY").fontWeight(.bold)
            Text(" | ")
            Text("14 Dec 2023 12:10 PM")
        }
        .font(.caption)
        .frame(height: 12)
    }
}
