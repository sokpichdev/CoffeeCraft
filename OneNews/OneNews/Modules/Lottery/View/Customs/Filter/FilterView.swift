//
//  FilterView.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct FilterView: View {
    //    @State var isReseted: Bool = false
    var body: some View {
        Divider()
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10){
                    CustomLabel(text: "Select Lotteries")
                    FilterSection(countryName: "Cambodia", numberOfResults: 2)
                    FilterSection(countryName: "China", numberOfResults: 6)
                    FilterSection(countryName: "Singapore", numberOfResults: 0)
                    FilterSection(countryName: "Thailand", numberOfResults: 3)
                    FilterSection(countryName: "Malaysia", numberOfResults: 4)
                    FilterSection(countryName: "Vietnam", numberOfResults: 1)
                    
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .background(Color.background)
            }
            
            // Floating butotn at the bottom
            VStack {
                Spacer()
                Button(action: {
                    print("Apply filter")
                }) {
                    Text("Apply")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.main)
                        .foregroundStyle(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.background)
            }
        }
//        .edgesIgnoringSafeArea(.bottom)  // button overlays the scrollview
        .navigationTitle("Filter")
        .navigationBarItems(trailing: Button(action: {
            //            isReseted = true
        }) {
            Button(action: {}) {
                Text("Reset")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.letters.opacity(0.3), lineWidth: 1))
            .cornerRadius(25)
            .foregroundStyle(.letters)
        })
        .background(Color.background)
    }
}
