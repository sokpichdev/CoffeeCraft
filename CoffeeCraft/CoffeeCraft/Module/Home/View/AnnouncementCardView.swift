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
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(announcement.description ?? "")
                    .font(.subheadline)
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

struct AnnouncementCardShimmerView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ShimmerView(cornerRadius: 0).frame(width: UIScreen.main.bounds.width - 32, height: 200)
            VStack(alignment: .leading, spacing: 5) {
                ShimmerView().frame(width: UIScreen.main.bounds.width * 0.4, height: 17)
                
                ShimmerView().frame(height: 15)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
