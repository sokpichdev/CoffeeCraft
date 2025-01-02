//
//  Album.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//
import SwiftUI

struct SideMenuView1: View {
    @State var index: Int = 0
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if self.index == 0 { Color.optionBtn1 }
                else if self.index == 1 { Color.optionBtn1 }
                else if self.index == 2 { Color.optionBtn1 }
                else if self.index == 3 { Color.optionBtn1 }
                else { Color.lightYellow }
            }
            CircleTabView(index: self.$index)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct CircleTabView: View {
    @Binding var index: Int
    var body: some View {
        HStack {
            Button(action: {
                self.index = 0
            }) {
                VStack {
                    if self.index != 0 {
                        normalImage("house")
                    } else {
                        clickedImage("house")
                    }
                }
            }
            Spacer(minLength: 15)
            
            Button(action: {
                self.index = 1
            }) {
                VStack {
                    if self.index != 1 {
                        normalImage("magnifyingglass")
                    } else {
                        clickedImage("magnifyingglass")
                    }
                }
            }
            Spacer(minLength: 15)
            
            Button(action: {
                self.index = 2
            }) {
                VStack {
                    if self.index != 2 {
                        normalImage("heart")
                    } else {
                        clickedImage("heart")
                    }
                }
            }
            Spacer(minLength: 15)
            
            Button(action: {
                self.index = 3
            }) {
                VStack {
                    if self.index != 3 {
                        normalImage("person")
                    } else {
                        clickedImage("person")
                    }
                }
            }
            Spacer(minLength: 15)
        }
        .frame(maxHeight: 80)
        .padding(.vertical, -10)
        .padding(.horizontal, 25)
        .background(Color.white)
        .animation(.spring())
    }
    
    private var clickedImage: (String) -> AnyView {
        { systemImageName in
            AnyView(
                VStack {
                    ZStack {
                        // Outer circle (border)
                        Circle()
                            .stroke(Color.optionBtn1, lineWidth: 20) // You can adjust the lineWidth for the border
                            .frame(width: 50, height: 50)  // Slightly bigger than the image to show the border
                            .offset(y: -20)
                        // Inner image inside the circle
                        Image(systemName: systemImageName)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.main)
                            .padding(8) // Adds padding around the image to ensure it's inside the circle
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(y: -30)
                            .padding(.bottom, -20)
                    }
                    // Text stays fixed below the image
                    Text(systemImageName)
                        .foregroundColor(Color.black.opacity(0.7))
                        .offset(y: 20) // Ensures the text stays in place
                }
            )
        }
    }
    
    private var normalImage: (String) -> AnyView {
        { systemImageName in
            AnyView(
                VStack {
                    Image(systemName: systemImageName)
                        .foregroundColor(.black.opacity(0.2))
                        .padding(8) // Adds a little padding around the image
                        .background(Color.white)
                        .clipShape(Circle())
                    // Text stays fixed below the image
                    Text(systemImageName)
                        .foregroundColor(Color.black.opacity(0.7))
                        .offset(y: 20) // Ensures the text stays in place
                }
            )
        }
    }
}
