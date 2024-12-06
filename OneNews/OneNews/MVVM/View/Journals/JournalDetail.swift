//
//  JournalDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalDetail: View {
    @ObservedObject var viewModel = NewsViewModel()
    @State private var selectedIndex: Int = 0 /// Tracks the currently selected index
    @State private var isSheetPresented = false /// Tracks sheet presentation
    
    // test data
    let imageARray = [Image(.issue), Image(.recent), Image(.basketball), Image(.football), Image(.giannis), Image(.barceVSmancity), Image(.lottery)]
    
    var body: some View {
        VStack {
            /// Full-size Images with TabView
            TabView(selection: $selectedIndex) {
                ForEach(imageARray.indices, id: \.self) { index in
                    imageARray[index]
                        .resizable()
                        .scaledToFit() // this case, use Fit, so it won't overlap on the other
                        .frame(height: 480)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.bottom, 10)
                        .tag(index) /// Links each page to its index
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hides the default page dots
            .frame(height: 500)
            
            /// Issue Images
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imageARray.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedIndex = index /// Sync selected page when tapping on an issue
                            }
                        }) {
                            VStack {
                                VStack {
                                    imageARray[index]
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 140)
                                        .clipped()
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIndex == index ? Color.main: Color.clear, lineWidth: 4)
                                        )
                                }
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                
                                Text("2023-\(index)")
                                    .foregroundColor(selectedIndex == index ? .main : .black)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                //                .onchange(of: selectedIndex)
            }
            .frame(height: 170)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Name of the journal")
        .navigationBarItems(trailing: Button(action: {
            isSheetPresented = true /// Toggle sheet presentation
        }) {
            Image(.calendar)
                .resizable()
                .frame(width: 20, height: 20)
        })
        .sheet(isPresented: $isSheetPresented) {
            SheetContentView()
                .presentationDetents([.height(400)])
        }
        .background(Color(UIColor.systemGray5))
    }
    
    
}
