//
//  JournalDetail.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//
import SwiftUI

struct JournalDetail: View {
    @ObservedObject var viewModel = ContentViewModel()
    @State private var isSheetPresented = false // State to track sheet presentation

    var body: some View {
        VStack {
            Image(.full)
                .resizable()
                .scaledToFit()
                .frame(height: 480)
                .cornerRadius(10)
                .clipped()
                .padding(.bottom, 10)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.news.indices, id:\.self) { index in
                            Button(action: {
                                print("clicked")
                            }) {
                                VStack {
                                    Image(.issue)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 140)
                                        .clipped()
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    
                                    Text("2023-234")
                                        .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                }
                .frame(height: 170)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .navigationTitle("Name of the journal")
        .navigationBarItems(trailing: Button(action: {
            isSheetPresented = true // Toggle sheet presentation
        }) {
            Image(.calendar) // Example button icon
                .resizable()
                .frame(width: 20, height: 20)
        })
        .sheet(isPresented: $isSheetPresented) {
            SheetContentView() // Replace with your desired sheet content
                .presentationDetents([.height(400)])
        }
    }
}

struct SheetContentView: View {
    var body: some View {
        VStack {
            Text("This is a sheet")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

#Preview {
    JournalDetail()
}
