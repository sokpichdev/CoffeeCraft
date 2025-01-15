//
//  ForgotPasswordView.swift
//  OneNews
//
//  Created by Sok Pich on 12/31/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var authVM: AuthViewModel
    @State var navigatedToChangedPassword: Bool = false
    var body: some View {
        VStack(spacing: 0){
            CustomNavigation()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0){
                    CustomLabel(text: "Forgot Password", font: .largeTitle, fontWeight: .semibold, textColor: .main)
                    
                    UnderLineView()
                }
                .padding(.vertical, 30)
                
                UserNameTextField(authVM: authVM)
                OTPTextField(authVM: authVM)
                PasswordTextField(authVM: authVM, passType: .newPassword)
                PasswordTextField(authVM: authVM, passType: .confirmPassword)
                AuthButton(btnType: .confirm) {
                    if authVM.validateInputs() {
                        print("Password changed successfully")
                        navigatedToChangedPassword = true
                    } else {
                        print(authVM.validationError ?? "Unknowrn Error")
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
        .background(Color.background)
        .background(
            NavigationLink("",
                           destination: LoginAfterChangePassView(),
                          isActive: $navigatedToChangedPassword)
        )
    }
}
