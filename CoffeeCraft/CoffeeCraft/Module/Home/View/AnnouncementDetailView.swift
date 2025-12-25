//
//  AnnouncementDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/18/25.
//
import SwiftUI

struct AnnouncementDetailView: View {
    let announcement: Announcement
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                AsyncImageCard(
                    imageURL: announcement.imageName ?? "",
                    height: 240,
                    width: UIScreen.main.bounds.width,
                    corner: 0
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(announcement.title ?? "")
                        .font(.title2.bold())
                    
                    Text(announcement.description ?? "")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
    }
}
