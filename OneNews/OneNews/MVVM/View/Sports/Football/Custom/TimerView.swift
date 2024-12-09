//
//  TimerView.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct TimerView: View {
    @State var time: Int = 0
    var body: some View {
        HStack {
            Spacer()
            Text("\(time)'")
                .font(.system(size: 12, weight: .regular))
            
            Image(systemName: "timer")
                .resizable()
                .scaledToFit()
                .frame(minWidth: 20, maxWidth: 20)
        }
        .padding(.top, 10)
        .padding(.trailing, 10)
        .frame(height: 20)  //Consistent height for top section
        .foregroundStyle(.red)
    }
}

#Preview {
    TimerView(time: 23)
}
