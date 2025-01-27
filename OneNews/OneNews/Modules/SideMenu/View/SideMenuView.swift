//
//  SideMenuView.swift
//  OneNews
//
//  Created by Sok Pich on 12/24/24.
//

import SwiftUI

struct SideMenuView: View {
    @StateObject var authVM = AuthViewModel()
    @Binding var isSideMenuOpen: Bool
    @Binding var dragOffset: CGFloat// Tracks the drag offset
    @AppStorage("isDarkMode") private var isDarkMode = UserPreference.shared.getIsDarkMode()
    @AppStorage("authToken") var authToken: String?
    
    var body: some View  {
        
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                if authToken != "" {
                    VStack (alignment: .leading){
                        Text("This is me").font(.headline).fontWeight(.bold)
                        Text("@gmail").font(.subheadline).fontWeight(.light)
                    }
                } else {
                    VStack (alignment: .leading){
                        Text("Login or Register").font(.headline).fontWeight(.bold)
                        Text("Manage Account").font(.subheadline).fontWeight(.light)
                    }
                    Spacer()
                    withAnimation{
                        NavigationLink(destination: LoginView()) {
                            Image(.frontBtn)
                                .resizable()
                                .frame(width: 7.5, height: 15)
                                .padding(10)
                                .background(Color.main)
                                .clipShape(Circle())
                        }
                    }

                }
            }
            Divider().padding(.vertical, 16)
            items("Language", "Language")
            NavigationLink(destination: ProfileView()) { items("Profile","Profile") }
            HStack{
                withAnimation(.smooth){  items("LightDarkMode", isDarkMode ? "Dark mode" : "Light mode") }
                Spacer()
                Button(action: {
                    withAnimation(.linear(duration: 0.5)) {
                        isDarkMode.toggle()
                        UserPreference.shared.setIsDarkMode(set: isDarkMode)
                    }
                }, label: {
                    SwitcherView(isOn: $isDarkMode)
                })
            }
            NavigationLink(destination: SupportView()) { items("Support","Support") }
            NavigationLink(destination: TermConditionView()) { items("Terms & Conditions","Terms & Conditions") }
            NavigationLink(destination: PrivacyPolicyView()) { items("Privacy Policy","Privacy Policy") }
            if authToken != "" {
                Button(action: {
                    authVM.logoutUser()
//                    authToken = ""
                }) {
                    items("Logout","Logout")
                }
            }
            Divider().padding(.vertical, 16)
            Spacer()
            
            Text("Download Our Application")
                .font(.subheadline)
                .foregroundColor(Color.letters.opacity(0.5))
            downloadButton("iOS", "iOS")
            downloadButton("android", "android")
            Spacer()
        }
        .padding(16)
        .frame(width: 300)
        .background(Color.optionBtn2)
        .foregroundColor(.letters)
        .transition(.move(edge: .leading))
        .zIndex(1)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.translation.width
                    if newOffset < 0 { // allow only dragg lef tonly
                        dragOffset = newOffset
                    }
                }
                .onEnded { value in
                    if value.translation.width < -150 { // threshold to close
                        // close side menu when swiped lft
                        withAnimation {
                            isSideMenuOpen = false
                            dragOffset = 0
                        }
                    } else {
                        withAnimation {
                            dragOffset = 0
                        }
                    }
                }
        )
        .transition(.move(edge: .leading))
        .onAppear() {
            print("token: \(authToken)")
        }
    }
    
    private var items: (String, String) -> AnyView {
        { imageName, itemName in
            AnyView(
                HStack {
                    CusImage(ImageName: imageName)
                    Text(itemName)
                }
            )
        }
    }
    private var downloadButton: (String, String) -> AnyView {
        { imageName, itemName in
            AnyView(
                HStack {
                    CusImage(ImageName: imageName)
                    VStack(alignment: .leading) {
                        Text("Download for    ").font(.subheadline)
                        Text(itemName).font(.subheadline).fontWeight(.bold)
                    }
                }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
//                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.darkPurple.opacity(0.1), Color.darkPurple.opacity(0.5), Color.darkPurple.opacity(0.9)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.main, lineWidth: 0.5))
            )
        }
    }
}
