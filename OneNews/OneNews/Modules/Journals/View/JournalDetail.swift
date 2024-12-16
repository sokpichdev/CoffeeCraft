//
//  JournalDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalDetail: View {
    var ablumID: Int
    var issueYear: String
    var issueNo: String = "100"
    
    @StateObject var jdVM = JournalDetailViewModel()
    @State private var selectedIndex: Int = 0
    @State private var isSheetPresented = false
    
    var body: some View {
        Divider()
        VStack {
            /// Full-size Images with Tabiew
            TabView(selection: $selectedIndex) {
                ForEach(jdVM.JD.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: jdVM.JD[index].attachments ?? "")) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5) // makes the full image flexible while occupying 50% of the screen height.
            Spacer()
            
            /// Issue Images
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(jdVM.JD.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedIndex = index
                            }
                        }) {
                            VStack {
                                AsyncImage(url: URL(string: jdVM.JD[index].attachments ?? "")) { image in
                                    image.resizable()
                                        .scaledToFill() // for issues to ensure they fill the defined frame without distortion.
                                        .frame(width: 90, height: 140)
                                        .clipped()
                                        .shadow(radius: 5)
                                        .cornerRadius(10)
                                        .padding(5)
                                        .background(Color.optionBtn1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIndex == index ? Color.main : Color.clear, lineWidth: 2)
                                        )
                                        .cornerRadius(10)
                                } placeholder: {
                                    ProgressView()
                                }
                                    
                                Text("\(jdVM.JD[index].issueYear ?? "-") - \(jdVM.JD[index].issueNo ?? "-")")
                                    .foregroundColor(selectedIndex == index ? .main : .letters)
                            }
                        }
                    }
                }
            }
            .frame(height: 170)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Name of the journal")
        .navigationBarItems(trailing: Button(action: {
            isSheetPresented = true
        }) {
            Image(.calendar)
                .resizable()
                .frame(width: 20, height: 20)
        })
        .sheet(isPresented: $isSheetPresented) {
            SheetContentView()
                .presentationDetents([.height(400)])
        }
        .background(Color.background)
        .onAppear() {
            jdVM.fetchJournalDetail(albumID: ablumID, issueYear: issueYear)
        }
    }
}

//struct JournalDetail: View {
//    var body: some View {
//        Text("hi")
//    }
//}
