//
//  MatchToggleButton.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//
import SwiftUI

struct MatchToggleButton: View {
    @ObservedObject var sportDateVM: SportDatesViewModel

    let selectedType: MatchType
    let title: String
    let action: () -> Void
    
    var isSelected: Bool {
        sportDateVM.matchType == selectedType
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color.main : Color.optionBtn2)
                .foregroundColor(isSelected ? .white : Color.letters)
                .cornerRadius(8)
        }
    }
}
