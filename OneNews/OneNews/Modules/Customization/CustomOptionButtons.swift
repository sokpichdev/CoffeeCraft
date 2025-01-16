//
//  CustomedOptionButtons.swift
//  OneNews
//
//  Created by Sok Pich on 12/6/24.
//

import SwiftUI

struct CustomOptionButtons: View {
    var title: String
    var imageName: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(isSelected ? "Clicked\(imageName)" : imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.03) // Adjust height relative to screen size
                
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .main : .letters)
            }
            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.05) // Dynamic size
            .padding(UIScreen.main.bounds.height * 0.02) // Proportional padding
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.optionBtn2, .optionBtn1]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.main : Color.clear, lineWidth: 1)
            )
            .shadow(radius: 3, y: -3)
            
        }
    }
}
//struct CustomOptionButtons: View {
//    var title: String
//    var imageName: String
//    var isSelected: Bool
//    var action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 10) {
//                Image(isSelected ? "Clicked\(imageName)" : imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 20)
//                
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(isSelected ? .main : .gray)
//            }
//            .frame(maxWidth: (UIScreen.main.bounds.size.width - 32), minHeight: 40)
//            .padding(16)
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color(.systemGray6), .white, Color(.systemGray4)]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            ) // Background gradient
//            
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(isSelected ? Color.main : Color.clear, lineWidth: 2) // Add border
//            )
//            .shadow(radius: 5)
////            .padding(5)
//        }
//    }
//}
