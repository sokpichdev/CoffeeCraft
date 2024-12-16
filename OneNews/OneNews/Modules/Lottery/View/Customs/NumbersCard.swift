//
//  TwentyNumberCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//
import SwiftUI

struct NumbersCard: View {
    @State var lists: [Int] = [] // Changed to 1D array

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Gold 4D")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(10)
            Divider().background(Color.white)
            Spacer()
            
            // Circles in rows
            VStack {
                if lists.count >= 20 {
                    HStack(spacing: -5) {
                        ForEach(lists.prefix(10), id: \.self) { number in
                            CircleView(number: number)
                        }
                    }
                    HStack(spacing: -5) {
                        ForEach(lists.suffix(10), id: \.self) { number in
                            CircleView(number: number)
                        }
                    }
                } else {
                    HStack(spacing: -5) {
                        ForEach(lists, id: \.self) { number in
                            CircleView(number: number)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Result")
                    .font(.caption)
                Spacer()
                Text("28 Oct, Sat. 03:30 PM")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(10)
            .background(Color.black.opacity(0.15))
            .cornerRadius(15)
            .padding(10)
        }
        .foregroundStyle(Color.white)
        .frame(width: 300, height: 190)
        .background(gradientBackground) // Use computed property
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    // Computed property for gradient background
    private var gradientBackground: LinearGradient {
        switch lists.count {
        case 20:
            return LinearGradient(
                gradient: Gradient(colors: [Color.lightRed, Color.darkRed]),
                startPoint: .top,
                endPoint: .bottom
            )
        case 10:
            return LinearGradient(
                gradient: Gradient(colors: [Color.lightYellow, Color.darkYellow]),
                startPoint: .top,
                endPoint: .bottom
            )
        case 5:
            return LinearGradient(
                gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color.lightBlueBerry, Color.darkBlueBerry]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
