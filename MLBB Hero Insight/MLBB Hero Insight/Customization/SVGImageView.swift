//
//  SVGImageView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/25/25.
//
import SwiftUI
import SVGKit

struct SVGImageView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView() // Or any placeholder
            }
        }
        .onAppear {
            loadSVGAsync(from: url)
        }
    }

    private func loadSVGAsync(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let svgImage = SVGKImage(data: data),
                  let uiImage = svgImage.uiImage else {
                return
            }
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}
