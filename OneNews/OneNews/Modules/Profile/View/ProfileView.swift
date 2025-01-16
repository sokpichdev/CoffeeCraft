//
//  ProfileView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI
//
//  ProfileView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var authVM = AuthViewModel()
    let buttonList = [
        ("Profile", "Personal Info"),
        ("Announcement", "Announcement"),
        ("Feedback", "Feedback"),
        ("dotdotdot", "")
    ]
    
    @State private var selectedButtonIndex: Int = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(buttonList.indices, id: \.self) { index in
                    if index == 3 {
                        VStack{
                            SegmentedButtonWithImage(imageName: buttonList[index].0, title: buttonList[index].1, isSelected: selectedButtonIndex == index) {
                                withAnimation(.easeInOut){
                                    selectedButtonIndex = index
                                }
                            }
                            Divider().frame(height: 5).overlay(Color.gray)
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.1)
                    } else {
                        VStack{
                            SegmentedButtonWithImage(imageName: buttonList[index].0, title: buttonList[index].1, isSelected: selectedButtonIndex == index) {
                                withAnimation(.easeInOut){
                                    selectedButtonIndex = index
                                }
                            }
                            Divider().frame(height: 5).overlay(selectedButtonIndex == index ? Color.main : Color.gray)
                        }
                    }
                }
            }
            .padding(.top, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.optionBtn2, .optionBtn1]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
            if selectedButtonIndex == 0 {
                CustomLabel(text: "Change Password")
                PasswordTextField(authVM: authVM, passType: .currentPassword)
                PasswordTextField(authVM: authVM, passType: .newPassword)
                PasswordTextField(authVM: authVM, passType: .confirmPassword)
            } else if selectedButtonIndex == 1 {
                Text("\(buttonList[1].0)")
            } else if selectedButtonIndex == 2 {
                Text("\(buttonList[2].0)")
            } else {
                Text("\(buttonList[3].0)")
            }
            Spacer()
        }
        .padding(16)
    }
}

