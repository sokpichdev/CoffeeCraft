//
//  CustomTabView.swift
//  MyWallet
//
//  Created by Sok Pich on 5/14/25.
//

import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            TabView(selection: $selectedTab) {
                Text("Home View")
                    .tag(0)
                Text("Analytics View")
                    .tag(1)
                // No tag 2 for the central button
                Text("Notification View")
                    .tag(3)
                Text("Profile View")
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Custom Tab Bar
            HStack(spacing: 0) {
                TabItemView(iconName: "house.fill", tabIndex: 0, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity) // Distribute space

                TabItemView(iconName: "chart.bar.fill", tabIndex: 1, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity) // Distribute space

                // Empty Spacer to create space for the central button
                Spacer()
                    .frame(width: 80) // Adjust width as needed

                TabItemView(iconName: "bell.fill", tabIndex: 3, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity) // Distribute space

                TabItemView(iconName: "person.fill", tabIndex: 4, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity) // Distribute space
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2))
            .overlay(alignment: .top) { // Overlay the central button
                Button {
                    // Handle central action
                    print("Central action tapped")
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGreen))
                            .frame(width: 60, height: 60)
                        Circle()
                            .fill(Color(.systemOrange))
                            .frame(width: 54, height: 54)
                        Image(systemName: "viewfinder")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .offset(y: -20) // Adjust vertical position
                }
            }
            .padding(.bottom, 10) // Add some bottom padding to the entire bar
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

struct TabItemView: View {
    let iconName: String
    let tabIndex: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            selectedTab = tabIndex
        } label: {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(selectedTab == tabIndex ? Color(.systemGreen) : Color.gray)
                .frame(maxWidth: .infinity)
        }
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView()
    }
}
