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
                .background(isSelected ? Color.main : Color.optionBtn1)
                .foregroundColor(isSelected ? .white : Color.letters)
//                .cornerRadius(8)
        }
    }
}

struct SegmentedButtonWithImage: View {
    
    let imageName: String
    let title: String
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack{
                Image(isSelected ? "Clicked\(imageName)" : imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.03) // Adjust height relative to screen size
                
                Text(title)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(isSelected ? .main : Color.letters)
                
            }
        }
    }
}

