//
//  UsersView.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct UsersView: View {
    
    //MARK:- PROPERTIES
    @StateObject var usersVM = UsersViewModel()
    
    //MARK:- BODY
    var body: some View {
        NavigationView{
            ScrollView {
                LazyVStack {
                    ForEach(usersVM.users, id: \.self) { user in
                        UserView(user: user)
                            .onAppear(){
                                usersVM.loadMoreContent(currentItem: user)
                            }
                    }
                }
            }
            .navigationTitle("Users")
            
        }
    }
}
