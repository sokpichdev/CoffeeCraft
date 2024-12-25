//
//  RegisterView.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine

struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0){
                CustomLabel(text: "Register", font: .largeTitle, fontWeight: .semibold, textColor: .main)
                
                UnderLineView()
            }
            .padding(.vertical, 30)
            
            UserNameTextField(authVM: authVM)
            OTPTextField(authVM: authVM)
            PasswordTextField(authVM: authVM)
            ConfirmPasswordTextField(authVM: authVM)
            SignUpButton()
            Spacer()
        }
        .customBackButton()
        .padding(16)
    }
}
