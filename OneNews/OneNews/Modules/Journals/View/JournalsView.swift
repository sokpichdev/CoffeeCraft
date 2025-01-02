//
//  JournalsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalsView: View {
    @StateObject var journalVM = JournalsViewModel()  // ViewModel for the journals
    
    var body: some View {
        ScrollView {
            RecommendedView()  // Other view component
            
            VStack {
                // Header Label
                HStack {
                    CustomLabel(text: "Recent Journals")
                    Spacer()
                }
                .padding(.vertical, 10)
                
                // Journals List
                if !journalVM.journals.isEmpty {
                    ForEach(journalVM.journals, id: \.id) { album in
                        NavigationLink {
                            JournalDetailView(ablumID: album.id ?? 2, issueYear: album.journal?.issueYear ?? "", albumTitle: album.name ?? "")
                        } label: {
                            JournalCard(album: album) 
                        }
                        .foregroundStyle(Color.letters)
                    }
                } else {
                    Text("No journals available.")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            
            .onAppear {
                journalVM.fetchJournals()  // Fetch journals on view load
            }
        }
        .background(Color.optionBtn1)
    }
}

#Preview {
    JournalsView()
}
