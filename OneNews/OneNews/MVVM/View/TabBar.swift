//
//  TabBar.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct TabBar: View {
    let tabBarItems = ["News","Journals","Sports","Lottery","Products"]
    @State var selectedTabBarIndex: Int = 0
    var body: some View {
        NavigationView {
            VStack(spacing: 0){
                NavBar()
                Spacer()
                // Display the selected View
                selectedView
                HStack(spacing: 0) { // no spacing for equal distribution
                    ForEach(tabBarItems.indices, id:\.self) { index in
                        Button(action: {
                            // Btn 1
                            selectedTabBarIndex = index
                        }) {
                            
                            VStack(spacing: 5){
                                Image(selectedTabBarIndex == index ? "Clicked\(tabBarItems[index])" : "\(tabBarItems[index])")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text(tabBarItems[index])
                                    .font(.caption)
                                    .foregroundColor(selectedTabBarIndex == index ? .main : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(13)
                        }
                    }
                }
                .frame(height: 50)
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
            ProductsView()
        default:
            Text(" ? ? ? ")
        }
    }
}

#Preview {
    TabBar(selectedTabBarIndex: 0)
}
