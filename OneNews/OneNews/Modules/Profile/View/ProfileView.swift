//
//  ProfileView.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//
import SwiftUI
import UIKit
import PhotosUI

struct ProfileView: View {
    @StateObject var authVM = AuthViewModel()
    @State var email: String = ""
    @State var feedbackContent: String = ""
//    @State var nickname: String = ""
    @State private var isSave: Bool = false
    @State private var isSheetPresented = false
    
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    
    let buttonList = [("Profile", "Personal Info"), ("Announcement", "Announcement"), ("Feedback", "Feedback"), ("dotdotdot", "")]
    
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
                        Button(action: {
                            showActionSheet.toggle()
                        }) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                CusImage(ImageName: "UserPF", width: 40, height: 40)
                            }
                        }
                        .frame(height: 50)
                        if isSave {
                            TextField("Enter your nickname", text: $authVM.nickname).font(.subheadline)
                        } else {
                            Text(authVM.nickname.isEmpty ? "Nickname" : authVM.nickname).font(.subheadline)
                        }
                        Spacer()
                        HStack(spacing: 5){
                            Button(action: {
                                isSave.toggle()
                                if !isSave {
                                    authVM.saveUserData()
                                }
                            }) {
                                if !isSave {
                                    if authVM.nickname == ""{
                                        CusImage(ImageName: "addSign")
                                        Text("Add").font(.headline).fontWeight(.ultraLight)
                                        
                                    } else {
                                        CusImage(ImageName: "Edit")
                                        Text("Edit").font(.headline).fontWeight(.ultraLight)
                                    }
                                } else {
                                    Text("Save").font(.headline).fontWeight(.bold).foregroundColor(Color.white)
                                }
                            }
                            .foregroundColor(Color.letters)
                            .frame(height: 30)
                            .padding(.horizontal, 5)
                            .background(!isSave ? Color.optionBtn2 : Color.main)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.main, lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 90)
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
                        .frame(height: 200)
                        .border(Color.optionBtn1, width: 1)
                        .cornerRadius(15)
                } else {
                }
                Spacer()
            }
            .padding(16)
        }
        .onAppear() {
            authVM.fetchUserData()
        }
        .sheet(isPresented: $isSheetPresented) {
            deleteAccountPopupView()
            .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(isPresented: $showCameraPicker, selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(isPresented: $showImagePicker, selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Select Profile Image"), message: Text("Choose an option"), buttons: [
                .default(Text("Camera")) {
                    showCameraPicker.toggle()
                },
                .default(Text("Gallery")) {
                    showImagePicker.toggle()
                },
                .cancel()
            ])
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

