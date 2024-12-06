//
//  JournalsView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalsView: View {

    @ObservedObject var viewModel = NewsViewModel()
    
    var body: some View {
        VStack{
            //                NavBar().disabled(true)
            trending.background(Color(.systemGray5))
            
            
            Spacer()
            //                TabBar()
        }
    }
    
    private var trending: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) { ////spacing between images
                    ForEach(viewModel.news.indices, id:\.self) { index in
                        Button(action: {
                            // do sth
                        }) {
                            NavigationLink(destination: JournalDetail()){
                                ZStack(alignment: .bottom) {
                                    // Image
                                    Image(.trending)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 145)
                                        .clipped()
                                        .shadow(radius: 2)
                                        .cornerRadius(15)
                                    
                                    // Black overlay with content
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .bottom, endPoint: .center)
                                    //                                    .cornerRadius(15)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Title \(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text("2024 - 168")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(1))
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.5))
                                    //                                    .cornerRadius(15)
                                    .padding(.bottom, 8)
//                                    .cornerRadius(15)
                                }
                                .cornerRadius(15)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 170)
            
            HStack{
                Text("Recent Journals")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }.padding(16)
            
            ForEach(1...10, id: \.self) { index in
                Button(action: {
                    // do sth
                    print("hi")
                }) {
                    NavigationLink(destination: JournalDetail()){
                        showJournals
                    }.foregroundStyle(.black)
                }
            }
        }
    }
    
    private var showJournals: some View {
        Section {
            HStack(spacing: 10){
                Image("recent")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 90)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                VStack {
                    HStack {
                        Spacer() // push to the right
                        Button(action: {
                            // do sth
                        }) {
                            Image("Star1").resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    HStack {
                        Text("Album name 1")
                            .font(.subheadline)
                        Spacer() // push to the left
                    }
                    
                    Section {
                        HStack {
                            Image("Calendar")
                                .resizable()
                                .frame(width: 15, height: 15, alignment: .leading)
                            
                            Text("2023")
                                
                            
                            Spacer()
                            
                            Text("Issue")
                                .fontWeight(.ultraLight)
                            
                            Text("099")
                        }
                        .font(.caption)
                        .fontWeight(.light)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                }
                //                    .background(.green)
                //                    Spacer()
            }.padding(.horizontal, 16)
                .background(.white)
        }
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}


#Preview {
    JournalsView()
}
