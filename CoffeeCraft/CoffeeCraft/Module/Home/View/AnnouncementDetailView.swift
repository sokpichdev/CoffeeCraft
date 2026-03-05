//
//  AnnouncementDetailView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/18/25.
//
import SwiftUI

struct AnnouncementDetailView: View {
    var announcement: Announcement?
    
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        CustomRefreshScrollView( {
            VStack(alignment: .leading, spacing: 16) {
                
                AsyncImageCard(
                    imageURL: announcement?.imageName ?? "",
                    height: 240,
                    width: UIScreen.main.bounds.width,
                    corner: 0
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(announcement?.title ?? "")
                        .font(.title2.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text(announcement?.description ?? "")
                        .font(.body)
                        .foregroundColor(.commonGray)
                }
                .padding(.horizontal)
            }
        })
        .background(Color.bgPrimary)
        .customNavigationBar("Announcement") {
            ToolBarButton.back {
                dismiss()
            }
        }
    }
}
