//
//  MoreResultsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct MoreResultsView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 5) {
                    Image(.result)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20, alignment: .leading)
                    
                    CustomLabel(text: "Rapid 11*5", textColor: .white, alignment: .center)
                    
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(.whiteStar)
                            .padding(10)
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(5)
                    }
                    Button(action: {
                        
                    }) {
                        Image(.whiteCalendar)
                            .padding(10)
                            .background(Color.black.opacity(0.15))
                            .cornerRadius(5)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                
                .padding(.horizontal, 16)
                .background(LinearGradient(gradient: Gradient(colors: [Color.darkPink, Color.lightPink]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(5)
                
                ForEach(1...5, id: \.self) { _ in
//                    ResultDetail(lists: ["12", "1", "6", "33", "76", "19", "23", "23", "54", "22", "12", "66", "89", "34", "56", "78", "90", "45", "34", "11"].shuffled())
//                        .cornerRadius(5)
                }
            }
            .padding(.horizontal, 16)
            .background(Color.background)
            .navigationTitle("Lottery Results")
        }
    }
}

#Preview {
    MoreResultsView()
}
