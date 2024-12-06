//
//  NavBar.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct NavBar: View {
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    // Menu Btn
                }) {
                    Image("Menu")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                }
                Spacer()
                
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
                }
            }
            .padding()
            .frame(height: 50)
            .overlay( // to put the title in front of the nav bar
                Image("title")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        }
    }
}

struct CusNavbar: View {
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
        
        .frame(maxWidth: .infinity, maxHeight: 50)
    }

}

#Preview {
    CusNavbar()
}
