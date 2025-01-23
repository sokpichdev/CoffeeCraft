//
//  NavBar.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct NavBar: View {
    @Binding var isSideMenuOpen: Bool
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    print("Side Menu seletected")
                    withAnimation{
                        isSideMenuOpen = true
                    }
                }) {
                    Image("Menu")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                }
                Spacer()
//                Image(.appLogo).frame
                Spacer()
                
                HStack(spacing: 5) {
                    Button(action: {
                        // Search Btn
                    }) {
                        Image("Search")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                    }
                    Button(action: {
                        // Star Btn
                    }) {
                        Image("Star")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                    }
                    Button(action: {
                        // Star Btn
                    }) {
                        Image("Star")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .trailing)
                    }
                }
            }
            .padding()
            .frame(height: 50)
            .overlay( // to put the title in front of the nav bar
                Image(.appLogo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
            )
            Divider().shadow(radius: 5, y: 2)
        }
    }
}

struct CusNav: View {
    var body: some View {
        HStack {
            
            Button(action: {
                print("nav bar btn pressed")
            }) {
                Image("Calendar")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .background(Color.white)
        
        .frame(maxWidth: .infinity, maxHeight: 50)
        
    }
    
}

