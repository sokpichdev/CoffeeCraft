//
//  LoginOTPView.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//
import SwiftUI

struct LoginOTPView: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 0){
            CustomNavigation()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        CustomLabel(text: "Login", font: .largeTitle, fontWeight: .semibold, textColor: .main, alignment: .leading)
                        CustomLabel(text: "via OTP", font: .largeTitle, fontWeight: .semibold, textColor: .letters, alignment: .leading)
                    }
                    UnderLineView()
                }
                .padding(.vertical, 30)
                
                OTPTextField(authVM: authVM)
                AuthButton(btnType: .login)
                
                Spacer()
            }
            .padding(16)
            .onAppear {
                authVM.startTimer()
            }
        }
        .background(Color.background)
        .onAppear() {
            authVM.clearTextField()
        }
    }

    
}

