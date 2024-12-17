//
//  JournalDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalDetailView: View {
    var ablumID: Int
    var issueYear: String
    var issueNo: String?
    var albumTitle: String = ""
    
    @StateObject var jdVM = JournalDetailViewModel()
    @StateObject var issueVM = IssueListViewModel()
    
    @State private var selectedIndex: Int = -1 // Initialize index to -1 (no selection)
    @State private var isSheetPresented = false
    
    var body: some View {
        Divider()
        VStack {
            /// Full-size Images with Tabiew
            TabView(selection: $selectedIndex) {
                ForEach(jdVM.JD.indices, id: \.self) { index in
                    LoadImages(image: jdVM.JD[index].attachments ?? "", maxWidth: .infinity, maxHeight: .infinity, isFit: true)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5) // makes the full image flexible while occupying 50% of the screen height.
            Spacer()
            
            /// Issue Images with ScrollViewReader to ensure selectedIndex stays visible
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(jdVM.JD.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedIndex = index
                                    proxy.scrollTo(index) // Ensure the thumbnail scrolls into view
                                }
                            }) {
                                VStack {
                                    LoadImages(image: jdVM.JD[index].attachments ?? "", maxWidth: 90, maxHeight: 140)
                                        .padding(5)
                                        .background(Color.optionBtn1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIndex == index ? Color.main : Color.clear, lineWidth: 1)
                                        )
                                        .cornerRadius(10)
                                    Text("\(jdVM.JD[index].issueYear ?? "-") - \(jdVM.JD[index].issueNo ?? "-")")
                                        .foregroundColor(selectedIndex == index ? .main : .letters)
                                }
                            }
                            .id(index) // a unique ID to each item for scrollTo
                        }
                    }
                }
                .frame(height: 170)
                .onChange(of: selectedIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center) // Automatically scroll to selectedIndex changes
                    }
                }
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle(albumTitle)
        .navigationBarItems(trailing: Button(action: {
            isSheetPresented = true
        }) {
            Image(.calendar)
                .resizable()
                .frame(width: 20, height: 20)
        })
        .sheet(isPresented: $isSheetPresented) {
            // Pass issueNo as a binding
            SheetContentView(
                issueListVM: issueVM, selectedIndex: $selectedIndex, defaultYear: issueYear, defaultIssue: issueNo ?? "")
            .presentationDetents([.height(400)])
        }
        .background(Color.background)
        .onAppear() {
            jdVM.fetchJournalDetail(albumID: ablumID, issueYear: issueYear)
            issueVM.fetchIssueList(albumID: ablumID, issueYear: issueYear)
            
            // After fetching data, find the index of the issueNo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Allow time for data fetch
                if let issueNo = issueNo {
                    if let index = jdVM.JD.firstIndex(where: { $0.issueNo == issueNo }) {
                        selectedIndex = index
                    }
                }
            }
        }
    }
}
