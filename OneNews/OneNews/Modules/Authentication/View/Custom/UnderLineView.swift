//
//  UnderLineView.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI

struct UnderLineView: View {
    var body: some View {
        Rectangle()
            .frame(width: 130, height: 5)
            .foregroundStyle(
                LinearGradient(gradient: Gradient(colors: [
                    Color.main.opacity(0.1),
                    Color.main.opacity(0.3),
                    Color.main
                ]), startPoint: .trailing, endPoint: .leading)
            )
            .blur(radius: 3)
            .cornerRadius(30)
    }
}
