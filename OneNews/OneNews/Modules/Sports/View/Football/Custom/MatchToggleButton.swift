//
//  MatchToggleButton.swift
//  OneNews
//
//  Created by Sok Pich on 12/9/24.
//
import SwiftUI

struct MatchToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color.main : Color.optionBtn2)
                .foregroundStyle(isSelected ? Color.white : Color.letters)
        }
    }
}
