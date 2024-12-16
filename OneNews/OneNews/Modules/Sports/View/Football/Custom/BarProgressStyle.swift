//
//  BarProgressStyle.swift
//  OneNews
//
//  Created by Sok Pich on 12/11/24.
//

import SwiftUI

struct BarProgressStyle: ProgressViewStyle {

    var color: Color = .main
    var height: Double = 25
    var labelFontStyle: Font = .body

    func makeBody(configuration: Configuration) -> some View {

        let progress = configuration.fractionCompleted ?? 0.0

        GeometryReader { geometry in

            VStack(alignment: .leading) {

//                configuration.label
//                    .font(labelFontStyle)

                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color.background)
                    .frame(height: height)
                    .frame(width: geometry.size.width)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(color)
                            .frame(width: geometry.size.width * progress)
                            .overlay {
                                if let currentValueLabel = configuration.currentValueLabel {

                                    currentValueLabel
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                    }

            }

        }
    }
}
