//
//  JournalsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalsView: View {
    @StateObject var journalVM = JournalsViewModel()  // Use @StateObject to manage the view model
    
    var body: some View {
        ScrollView {
            RecommendedView()
            VStack {
                HStack {
                    CustomLabel(text: "Recent Journals")
                    Spacer()
                }
                .padding(.vertical, 10)
                
                // Check if the journals array is not empty
                if !journalVM.journals.isEmpty {
                    ForEach(journalVM.journals, id: \.id) { album in

                        NavigationLink {
                            JournalDetail(ablumID: album.id ?? 2, issueYear: album.journal?.issueYear ?? "")
                        } label: {
                            showJournals(album: album)
                        }
                            .foregroundStyle(Color.letters)

                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.background)
            .onAppear {
                journalVM.fetchJournals() // Fetch journals when the view appears
            }
        }
        Spacer()
    }
    
    private func showJournals(album: AlbumModel) -> some View {
        
        VStack {
            HStack(spacing: 10) {
                if let cover = album.cover, let imageURL = URL(string: cover) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(10)
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                    }
                }
                
                VStack {
                    HStack {
                        Spacer() // Push to the right
                        Button(action: {
                            // Do something, like marking as favorite
                        }) {
                            Image("Star1").resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                    
                    HStack {
                        Text(album.name ?? "No name")
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer() // Push to the left
                    }
                    
                    VStack {
                        HStack {
                            Image("Calendar")
                                .resizable()
                                .frame(width: 15, height: 15, alignment: .leading)
                            
                            Text(album.journal?.issueYear ?? "")
                            
                            Spacer()
                            
                            Text("Issue")
                                .fontWeight(.ultraLight)
                            
                            Text(album.journal?.issueNo ?? "")
                        }
                        .font(.caption)
                        .foregroundStyle(Color.letters)
                        .padding(10)
                        .background(Color.background)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .padding(.trailing, 10)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 90)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.optionBtn2, .optionBtn2.opacity(0.5), .optionBtn2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .cornerRadius(10)
    }
}

#Preview {
    JournalsView()
}

//struct JournalCard: View {
//    var model: AlbumModel
//    var body: some View {
//
//    }
//}
