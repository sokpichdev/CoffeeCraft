//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by Sok Pich on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowSuccessAlert: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                isShowSuccessAlert.toggle()
            }) {
                Text("Show Full-Screen Alert")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .fullScreenCover(isPresented: $isShowSuccessAlert) {
            Alert(isShowSuccessAlert: $isShowSuccessAlert)
        }
    }
}

struct Alert: View {
    @Binding var isShowSuccessAlert: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 15) {
                Image(uiImage: .wallet)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .frame(width: 76, height: 76)
                    .background(Color.main)
                    .clipShape(Circle())
                
                Text("Success!")
                    .font(.custom("Poppins-Bold", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.main)
                
                Text("You have successfully sent your confirm payment!")
                    .font(.custom("Poppins-Regular", size: 12))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                Button(action: {
                    isShowSuccessAlert = false
                }, label: {
                    HStack(alignment: .center) {
                        Text("Continue Shopping")
                            .font(.custom("Poppins-Regular", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(Color.main)
                    .cornerRadius(100)
                })
            }
            .padding(20)
            .frame(width: 325, height: 325)
            .background(Color.white)
            .cornerRadius(20)
        }
    }
}

