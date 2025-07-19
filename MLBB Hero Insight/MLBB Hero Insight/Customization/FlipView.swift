//
//  FlipView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/25/25.
//
import SwiftUI

//struct FlipView<Front: View, Back: View>: View {
//    let front: Front
//    let back: Back
//    @Binding var isFlipped: Bool
//
//    var body: some View {
//        ZStack {
//                front
//                    .opacity(isFlipped ? 0.0 : 1.0)
//                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
//
//                back
//                    .opacity(isFlipped ? 1.0 : 0.0)
//                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // flips to front
//                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0)) // outer flip
//        }
//        .animation(.easeInOut(duration: 0.4), value: isFlipped)
//    }
//}
