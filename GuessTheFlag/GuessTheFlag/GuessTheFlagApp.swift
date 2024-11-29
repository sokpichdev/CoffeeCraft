//
//  GuessTheFlagApp.swift
//  GuessTheFlag
//
//  Created by Sok Pich on 11/28/24.
//

import SwiftUI
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
}
@main
struct GuessTheFlagApp: App {
    //@UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
//            NavigationView {
//                FirstView()
//                NewView()
//                ContentVieww()
//            }
            ContentView()
        }
    }
}

struct FirstView: View {
    @State var text = "Hello, World!"
    @State var textfield = ""
    @FocusState var focusState: Bool
    @GestureState var dragAmount = CGSize.zero
    @Namespace var name
    var body: some View {
//        VStack {
//            Text(text)
//            
//            NavigationLink {
//                SecondView(text: text)
//            } label: {
//                Text("Push")
//            }
//            
//
//            
//            TextField("Place holder", text: $textfield)
//                .focused($focusState)
//        }
//        .background(Color.red)
//        .onTapGesture {
//            focusState.toggle()
//        }
//        Image(systemName: "square.and.arrow.up.circle.fill")
//            .offset(dragAmount)
//            .gesture(
//                DragGesture().updating($dragAmount) { value, state, transaction in
//                    state = value.translation
//                }
//            )
        
        ScrollViewReader { scrollView in
            
            ScrollView(content: {
                VStack {
                    Color.red.frame(height: 100)
                        .id(name)
                    Color.blue.frame(height: 500)
                    Color.green.frame(height: 1000)
                    Button {
                        withAnimation {
                            
                            scrollView.scrollTo(name)
                        }
                    } label: {
                        Text("click")
                    }

                }
            })
        }
    }
}

struct SecondView: View {
//    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentmode
    
    @SceneStorage("usernameeeeeee") var user: String = ""
    var body: some View {
//        Text(viewModel.text)
//        Button {
//            viewModel.text = "to sth else"
//        } label: {
//            Text("change")
//        }
//
//        Button {
//            presentmode.wrappedValue.dismiss()
//        } label: {
//            Text("Change")
//        }

        Text(user)
        Button {
            user = "Hello heekekekek"
        } label: {
            Text("change")
        }

    }
}

struct NewView: View {
//    @StateObject var viewModel = ViewModel()
    @SceneStorage("usernameeeeeee") var user: String = ""
    var body: some View {
        VStack {
//            Text(viewModel.text)
            NavigationLink {
                SecondView()
//                    .environmentObject(viewModel)
            } label: {
                Text("Push")
            }
            Text(user)
        }
        .onAppear {
            print(user)
        }
    }
}

class ViewModel: ObservableObject {
    @Published var text: String = "Cambodia"
}


struct ContentVieww: View {
    @SceneStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("First View")
                .tabItem {
                    Label("First", systemImage: "1.circle")
                }
                .tag(0)
            
            Text("Second View")
                .tabItem {
                    Label("Second", systemImage: "2.circle")
                }
                .tag(1)
        }
    }
}

