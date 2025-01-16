//
//  TabBar.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct TabBar: View {
    @State var isSideMenuOpen: Bool = false
    @State var dragOffset: CGFloat = 0 // Tracks the drag offset
    let tabBarItems = ["News", "Journals", "Sports", "Lottery", "Profile"]
    @State var selectedTabBarIndex: Int = 0
    @AppStorage("isDarkMode") private var isDarkMode = UserPreference.shared.getIsDarkMode()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    NavBar(isSideMenuOpen: $isSideMenuOpen)
                    Spacer()
                    selectedView
                    HStack(spacing: 0) {
                        ForEach(tabBarItems.indices, id: \.self) { index in
                            Button(action: {
                                selectedTabBarIndex = index
                            }) {
                                VStack(spacing: 5) {
                                    ZStack {
                                        if selectedTabBarIndex == index {
                                            if #available(iOS 17.0, *) {
                                                Circle()
                                                    .fill(Color.optionBtn2)
                                                    .stroke(Color.background, lineWidth: 10)
                                                    .frame(width: 50, height: 50)
                                                    .offset(y: -15)
                                            } else {
                                                // Fallback on earlier versions
                                            }
                                        }
                                        Image(selectedTabBarIndex == index ? "Clicked\(tabBarItems[index])" : "\(tabBarItems[index])")
                                            .resizable().scaledToFit().frame(width: 20, height: 20)
                                            .background(Color.optionBtn2).offset(y: selectedTabBarIndex == index ? -15 : 0) // Moves up if selected
                                    }
                                    Text(tabBarItems[index]).font(.caption).foregroundColor(selectedTabBarIndex == index ? .main : .gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(13)
                            }
                        }
                    }
                    .frame(height: 50)
                }
                .background(Color.optionBtn2)
                .blur(radius: isSideMenuOpen ? 1 : 0)
                .disabled(isSideMenuOpen) // Disable interactions when the side menu is open
                .onTapGesture {
                    withAnimation {
                        isSideMenuOpen = false
                        dragOffset = 0
                    }
                }
                HStack {
                    if isSideMenuOpen {
                        SideMenuView(isSideMenuOpen: $isSideMenuOpen, dragOffset: $dragOffset)
                    }
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private var selectedView: some View {
        switch selectedTabBarIndex {
        case 0:
            NewsView()
        case 1:
            JournalsView()
        case 2:
            SportsView()
        case 3:
            LotteryView()
        case 4:
            ProfileView()
        default:
            Text(" ? ? ? ")
        }
    }
}
