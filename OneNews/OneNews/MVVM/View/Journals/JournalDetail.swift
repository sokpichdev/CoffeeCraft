//
//  JournalDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct JournalDetail: View {
    @ObservedObject var viewModel = NewsViewModel()
    @State private var selectedIndex: Int = 0
    @State private var isSheetPresented = false
    
    // Test data
    let imageArray = [Image(.issue), Image(.recent), Image(.basketball), Image(.football), Image(.giannis), Image(.barceVSmancity), Image(.lottery)]
    
    var body: some View {
        Divider()
        VStack {
            /// Full-size Images with TabView
            TabView(selection: $selectedIndex) {
                ForEach(imageArray.indices, id: \.self) { index in
                    imageArray[index]
                        .resizable()
                        .scaledToFit() // ensures images adapt to the screen width while maintaining their aspect ratio.
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // ensures components adjust to different screen sizes.
                        .cornerRadius(10)
                        .clipped()
                        .padding(.bottom, 10)
                        .tag(index)
                }
            }
//            .background(.yellow)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5) // makes the full image flexible while occupying 50% of the screen height.
            Spacer()
            
            /// Issue Images
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imageArray.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedIndex = index
                            }
                        }) {
                            VStack {
                                imageArray[index]
                                    .resizable()
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
                                Text("2023-\(index)")
                                    .foregroundColor(selectedIndex == index ? .main : .letters)
                            }
                        }
                    }
                }
//                .padding(.horizontal, 16)
            }
            .frame(height: 170)
            
            Spacer()
        }
//        .background(.green)
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
    }
}
