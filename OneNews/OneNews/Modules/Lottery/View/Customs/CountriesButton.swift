//
//  CountriesButtons.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//

import SwiftUI

struct CountriesButton: View {
    var countryName: String
    var numberOfLottery: Int
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action() // Call the action closure passed from the parent
        }) {
            VStack(alignment: .center, spacing: 5) {
                CountryCircle(countryName: countryName)
                    .overlay(
                        Circle()
                            .stroke(Color.optionBtn2, lineWidth: 4) // Adds a border
                    )
                    .shadow(radius: 5, y: 4) // Adds a shadow
                
                Text(countryName)
                    .font(.callout)
                Text("\(numberOfLottery)")
                    .font(.caption2)
                    .fontWeight(.light)
            }
            .frame(minWidth: 90, maxWidth: 100, minHeight: 100, maxHeight: 120)
            .background(Color.optionBtn2.opacity(0.5))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.main : Color.black.opacity(0.2), lineWidth: 1)
            )
            .padding(10)
            .background(.optionBtn2)
            .cornerRadius(5)
        }
        .foregroundStyle(isSelected ? Color.main : .letters)
    }
}
