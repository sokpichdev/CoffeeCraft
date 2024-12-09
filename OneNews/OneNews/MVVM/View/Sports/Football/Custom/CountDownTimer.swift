//
//  CountDownTimer.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//

import SwiftUI

struct CountDownTimer: View {
    @State var countDownTime: Int = 60
    
    var body: some View {
        VStack {
            Image(.countDown)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Text("3d 7h 55m")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.red)
        }
        .frame(width: 65, height: 50)
        .offset(y: -15)
    }
}
