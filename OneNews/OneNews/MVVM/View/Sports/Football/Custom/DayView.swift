//
//  DaysView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct DayView: View {
    let day: String
    let date: Int
    var body: some View {
        VStack {
            Text(day)
                .font(.system(size: 9, weight: .regular))
                .frame(width: 20, height: 12)
            
            Text("\(date)")
                .font(.system(size: 12, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
