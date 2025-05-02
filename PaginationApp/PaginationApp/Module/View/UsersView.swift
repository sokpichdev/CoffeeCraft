//
//  UsersView.swift
//  PaginationApp
//
//  Created by Sok Pich on 1/7/25.
//

import SwiftUI

struct UsersView: View {
    @StateObject var usersVM = UsersViewModel()

    var body: some View {
        NavigationView {
            Group {
                if usersVM.isFirstLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(usersVM.users, id: \.self) { user in
                                NavigationLink(destination: CharacterDetailView(user: user)) {
                                    UserView(user: user)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    usersVM.loadMoreContent(currentItem: user)
                                }
                            }

                            if usersVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding(.vertical)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Characters")
            .onAppear {
                if usersVM.users.isEmpty { // <- to avoid reloading if already loaded
                    usersVM.getUsers()
                }
            }
        }
    }
}
