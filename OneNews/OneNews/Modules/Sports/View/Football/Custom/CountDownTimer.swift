//
//  CountDownTimer.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct CountDownTimer: View {
    @State var countDownTime: String
    
    var body: some View {
        VStack {
            Image(.countDown)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Text(countDownTime)
            .font(.system(size: 10, weight: .regular))
            .foregroundStyle(.red)
            .lineLimit(2)
            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity)
        }
        .frame(width: 80, height: 50)
        .offset(y: -15)
    }
}
