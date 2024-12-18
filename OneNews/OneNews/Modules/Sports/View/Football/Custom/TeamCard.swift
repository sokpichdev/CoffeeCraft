//
//  TeamCard.swift
//  OneNews
//
//  Created by Sok Pich on 12/12/24.
//
import SwiftUI

struct TeamCard: View {
    var title: String = ""
    var leftTeamImage: String = ""
    var leftTeamName: String = ""
    var leftTeamScore: String = "0"
    
    var rightTeamImage: String
    var rightTeamName: String = ""
    var rightTeamScore: String = "0"
    
    var timer: String = ""
    var formattedDateTime: String = ""
    var isLive: Bool = false
    @State private var isLoading = true // Tracks if the image is loading

    var body: some View {
        VStack(spacing: 10) { // Background card
//            Spacer(minLength: 0)
            
            // Title section with a fixed height
            HStack { // section 1
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Allow the title to wrap to 2 lines maximum
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    .frame(maxWidth: .infinity, alignment: .center) // Center the title
            }
            .frame(height: 40)
//            .padding(.horizontal, 16)
//            Spacer(minLength: 0)
            
            HStack { // section 2
                TeamView(teamImage: leftTeamImage, teamName: leftTeamName) // Left team
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                ZStack { // Score and Live
                    VStack {
                        Text("\(leftTeamScore) - \(rightTeamScore)")
                            .foregroundColor(.white)
                    }
                    .frame(width: 65, height: 50)
                    .background(Color.black.opacity(0.1))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .cornerRadius(10)
                    if isLive {
                        LiveIndicator()
                            .offset(y: -25) // Position "Live" indicator
                    }
                }
                .frame(width: 65)
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName) // Right team
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            Spacer(minLength: 0)
            
            // Timer and Date section
            VStack {
                ZStack(alignment: .bottom) {
                    HStack {
                        Text(isLive ? timer : "FT")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(formattedDateTime)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: 40)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .background(Color.black.opacity(0.2))
                .shadow(radius: 5)
            }
        }
        .foregroundColor(Color.white)
        .frame(width: 330, height: 170)
        .background(LinearGradient(gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
