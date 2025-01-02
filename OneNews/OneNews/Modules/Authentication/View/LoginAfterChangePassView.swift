//
//  LoginAfterChangePassView.swift
//  OneNews
//
//  Created by Sok Pich on 12/31/24.
//

import SwiftUI

struct LoginAfterChangePassView: View {
    @State var NavigatedToLogin: Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(.passChanged)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            CustomLabel(text: "Password changed", font: .title, fontWeight: .bold, textColor: .main)
            CustomLabel(text: "You’ve successfully reset your password. Please use your new password to login.", font: .caption, fontWeight: .semibold,textColor: .letters, alignment: .center)
            AuthButton(btnType: .login, maxWidth: 150) {
                NavigatedToLogin = true
            }
        }
        .background(
            NavigationLink("",
                           destination: LoginView(),
                           isActive: $NavigatedToLogin)
        )
    }
}
