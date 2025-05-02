//
//  View.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct UserView: View {
    var user: User

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .padding()

            Text(user.name)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .background(Color.black)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

