//
//  AnnouncementCardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//
import SwiftUI

struct AnnouncementCardView: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImageCard(imageURL: announcement.imageName ?? "", height: 200, width: UIScreen.main.bounds.width - 32, corner: 0)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(announcement.title ?? "")
                    .font(.customHeadline)
                
                Text(announcement.description ?? "")
                    .font(.customSubheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
