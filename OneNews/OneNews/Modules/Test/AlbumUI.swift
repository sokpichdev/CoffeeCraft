//
//  AlbumUI.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//

import SwiftUI

struct AlbumUI: View  {
    @State private var albums: [Album] = []
        var body: some View {
            NavigationStack {
                List(albums) { album in
                    HStack {
                        AsyncImage(url: URL(string: album.url))
                        { phase in
                            switch phase {
                            case .failure: Image(systemName: "photo") .font(.largeTitle)
                            case .success(let image):
                                image.resizable()
                            default: ProgressView()
                                
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading) {
                            Text("\(album.id)").bold()
                            Text(album.title).bold().font(.title3)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.purple)
                .navigationTitle("Photos from API")
                .onAppear {
                    fetchRemoteData()
                }
            }
        }
    private func fetchRemoteData() {
            let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"  // optional
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                if let error = error {
                    print("Error while fetching data:", error)
                    return
                }

                guard let data = data else {
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode([Album].self, from: data)
                    // Assigning the data to the array
                    self.albums = decodedData
                } catch let jsonError {
                    print("Failed to decode json", jsonError)
                }
            }

            task.resume()
        }
}
