//
//  CircleView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct CircleView: View {
    var number: String = "0"
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .overlay(
                Text(number)
                    .font(.caption)
                    .foregroundColor(.black)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 10) // Adds a border
            )
            .shadow(radius: 10) // Adds a shadow
    }
}

struct CircleResult: View {
    var number: String = ""
    var color: String = "main"
    var animal: String = ""
    var lotCatID: Int
    var backgroundColor: Color = Color.percentage
    var foregroundColor: Color
    var body: some View {
        VStack(alignment: .center, spacing: 5){
            Circle()
                .fill(color == "optionBtn2" ? Color.optionBtn2: backgroundColor)
                .frame(width: 35, height: 35)
                .overlay(
                    Text(number)
                        .font(.caption)
                        .foregroundColor(foregroundColor)
                )
                .overlay(
                    color != "optionBtn2"
                    ? Circle()
                        .stroke(Color.from(string: color), lineWidth: lotCatID == 3 ? 2 : 1)
                    : nil
                )
                .shadow(radius: (lotCatID == 3) ? 0 : 2, y: (lotCatID == 3) ? 0 : 4)
            if lotCatID == 3 {
                Text(animal).font(.caption).foregroundColor(.letters)
            }
        }
    }
}
//struct CircleLotto: View {
//    var body: some View {
//        Text("lotto")
//    }
//}
