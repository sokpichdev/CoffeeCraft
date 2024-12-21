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
        VStack(spacing: 10) {
            // Section 1: Title (dynamic height)
            HStack {
                Text(title)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil) // Allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(16)
            
            .frame(height: 60)

            // Section 2: Teams and Score (static height)
            HStack {
                TeamView(teamImage: leftTeamImage, teamName: leftTeamName)
                    .frame(maxWidth: .infinity, alignment: .center)
                ZStack {
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
                            .offset(y: -25)
                    }
                }
                .frame(width: 65)
                TeamView(teamImage: rightTeamImage, teamName: rightTeamName)
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .frame(height: 80)

            // Section 3: Timer and Date (static height)
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
                    .padding(16)
                }
                .frame(maxHeight: 40)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .background(Color.black.opacity(0.2))
                .shadow(radius: 5)
                Spacer()
            }
            .frame(height: 40)
        }
        .foregroundColor(Color.white)
        .frame(width: 330, height: 180)
        .background(LinearGradient(gradient: Gradient(colors: [Color.lightGreen, Color.darkGreen]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
