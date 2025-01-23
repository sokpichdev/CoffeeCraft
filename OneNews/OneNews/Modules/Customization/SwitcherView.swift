//
//  SwitcherView.swift
//  OneNews
//
//  Created by Sok Pich on 1/3/25.
//

import SwiftUI

struct SwitcherView: View {
    @Binding var isOn: Bool
    var body: some View {
//        Toggle("", isOn: $isOn)
//            .fixedSize()
//            .scaleEffect(0.7)
//            .offset(x: 5)
//            .tint(Color.mainTabActive1)
//         let switchThumpOff = LinearGradient(
//            stops: [Gradient.Stop(color: Color.optionBtn1, location: 0)],
//            startPoint: UnitPoint(x: 0, y: 0),
//            endPoint: UnitPoint(x: 1, y: 1)
//        )
        let switchThumpOff = Color.red
        ZStack {
            Capsule()
                .fill(Color.gray)
            HStack {
                if !isOn {
                    Spacer()
                }
                Circle()
                    .fill(Color.main)
                if isOn {
                    Spacer()
                }
            }
            .padding(2)
        }
        .frame(width: 40, height: 22)
    }
}

