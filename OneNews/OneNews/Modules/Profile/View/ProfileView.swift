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
import UIKit

struct ProfileView: View {
    @StateObject var authVM = AuthViewModel()
    @State var email: String = ""
    @State var feedbackContent: String = ""
    @State var nickname: String = ""
    @State private var isSave: Bool = false
    @State private var isSheetPresented = false
    let buttonList = [
        ("Profile", "Personal Info"),
        ("Announcement", "Announcement"),
        ("Feedback", "Feedback"),
        ("dotdotdot", "")
    ]
    
    @State private var selectedButtonIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 0) {
                    ForEach(buttonList.indices, id: \.self) { index in
                        if index == 3 {
                            VStack {
                                SegmentedButtonWithImage(imageName: buttonList[index].0, title: buttonList[index].1, isSelected: selectedButtonIndex == index) {
                                    withAnimation(.easeInOut) {
                                        selectedButtonIndex = index
                                        isSheetPresented = true // Show the deleteAccountPopup
                                    }
                                }
                                Divider().frame(height: 5).overlay(Color.gray)
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.1)
                        }
                        else {
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
                .frame(maxWidth: .infinity, maxHeight: 100)
                .padding(.top, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.optionBtn1.opacity(0.5), .optionBtn1]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
                if selectedButtonIndex == 0 {
                    
                    HStack(spacing: 5) {
                        CusImage(ImageName: "UserPF", width: 50, height: 50)
                    
                        if nickname == "" {
                            Text("Nickname").font(.subheadline).fontWeight(.ultraLight)
                        } else {
                            TextField("NicNname", text: $nickname)
                        }
//                            Text("Sok Pich").font(.headline)
                        Spacer()
                        HStack(spacing: 5){
                            Button(action: {
                                isSave.toggle()
                            }) {
                                if !isSave {
                                    if nickname == ""{
                                        CusImage(ImageName: "addSign")
                                        Text("Add").font(.headline).fontWeight(.ultraLight)
                                    } else {
                                        CusImage(ImageName: "Edit")
                                        Text("Edit").font(.headline).fontWeight(.ultraLight)
                                    }
                                } else {
                                    Text("Save").font(.headline).fontWeight(.bold).foregroundColor(Color.letters)
                                }
                            }
                            .foregroundColor(Color.letters)
                            .frame(height: 50)
                            .padding(.horizontal, 5)
                            .background(nickname == "" ? Color.optionBtn2 : Color.main)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.main, lineWidth: 1))
                        }
                        .padding(.horizontal, 5).background(nickname == "" ? Color.optionBtn2 : Color.main).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.main, lineWidth: 1))

                    }
                    .frame(maxWidth: .infinity, maxHeight: 75)
                    .padding(.horizontal, 10)
                    .background(Color.optionBtn1)
                    .cornerRadius(10)
                    
                    CustomLabel(text: "Change Password")
                    PasswordTextField(authVM: authVM, passType: .currentPassword)
                    PasswordTextField(authVM: authVM, passType: .newPassword)
                    PasswordTextField(authVM: authVM, passType: .confirmPassword)
                    
                    if validateChangePassword() {
                        AuthButton(btnType: .confirm)
                    } else {
                        AuthButton(btnType: .confirm, bgColor: .optionBtn1, fgColor: .letters)
                    }
                    Spacer()
                    
                    
                    
                } else if selectedButtonIndex == 1 {
                    ForEach(1...6, id:\.self) {_ in
                        VStack(alignment: .leading) {
                            CustomLabel(text: "System Announcement", font: .headline, fontWeight: .bold)
                            Text("15 March 2023 00:00:00 AM").font(.subheadline).fontWeight(.ultraLight)
                            Text("Congratulations, your level has reached level 4. Upgrading to the next level requires 290 experience, which can be obtained through daily tasks and novice tasks in the task center.").font(.headline).fontWeight(.light)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.optionBtn1.opacity(0.5), .optionBtn1]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(10)
                    }
                } else if selectedButtonIndex == 2 {
                    TextField("Email*", text: $email)
                        .keyboardType(.twitter)
                        .padding(16)
                        .background(Color.optionBtn1)
                        .cornerRadius(100)
                    TextView(text: $feedbackContent, placeholder: "Feedback content*")
//                        .padding(16)
                        .frame(height: 200)
                        .border(Color.optionBtn1, width: 1)
                        .cornerRadius(15)
                } else {
                }
                Spacer()
            }
            .padding(16)
        }
        .sheet(isPresented: $isSheetPresented) {
            // Pass issueNo as a binding
            deleteAccountPopupView()
            .presentationDetents([.height(400)])
        }
    }
    
    func validateChangePassword() -> Bool {
        return authVM.newPassword == authVM.confirmPassword && !authVM.currentPassword.isEmpty && !authVM.newPassword.isEmpty && !authVM.confirmPassword.isEmpty
    }
}

struct deleteAccountPopupView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
