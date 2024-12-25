//
//  Album.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//
import SwiftUI

struct SideMenuView1: View {
    @State private var showMenu = false

    var body: some View {
        ZStack {
            // Main Content
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
                Text("Main Content")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .blur(radius: showMenu ? 10 : 0) // Add blur when the menu is open

            // Side Menu
            HStack {
                if showMenu {
                    VStack(alignment: .leading) {
                        Text("Menu Item 1")
                            .padding()
                        Text("Menu Item 2")
                            .padding()
                        Text("Menu Item 3")
                            .padding()
                        Spacer()
                    }
                    .frame(width: 250) // Adjust the width of the menu
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .transition(.move(edge: .leading)) // Smooth animation
                    .zIndex(1)
                }
                Spacer()
            }
            .onTapGesture {
                withAnimation {
                    showMenu = false
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

