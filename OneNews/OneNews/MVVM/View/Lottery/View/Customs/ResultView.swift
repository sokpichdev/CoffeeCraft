//
//  ResultView.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct ResultView: View {
    @State var lists: [Int] = [] // Changed to 1D array
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(spacing: 5) {
                Image(.result)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20, alignment: .leading)
                
                CustomLabel(text: "Rapid 11*5", textColor: .white, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(LinearGradient(gradient: Gradient(colors: [Color.darkPurple, Color.lightPurple]), startPoint: .leading, endPoint: .trailing))
            
            Text("DRAW ID - 56213")
                .font(.caption)
            
            HStack {
                Text("THURSDAY").fontWeight(.bold)
                Text(" | ")
                Text("14 Dec 2023 12:10 PM")
            }
            .font(.caption)
            .frame(height: 12)
            
            // Circles in rows
            VStack {
                if lists.count >= 20 {
                    HStack(spacing: -5) {
                        ForEach(lists.prefix(10), id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                    HStack(spacing: -5) {
                        ForEach(lists.suffix(10), id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                } else {
                    HStack(spacing: -5) {
                        ForEach(lists, id: \.self) { number in
                            CircleResult(number: number)
                        }
                    }
                }
            }
            Spacer()
            Button(action: {}) {
                Text("MORE RESULTS")
            }
            .padding(16)
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.letters, lineWidth: 1))
            .cornerRadius(25)
            .foregroundStyle(.letters)
            .padding(.bottom, 16)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .frame(height: 220)
        .background(Color.optionBtn2)
        .cornerRadius(5)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ResultView()
}

