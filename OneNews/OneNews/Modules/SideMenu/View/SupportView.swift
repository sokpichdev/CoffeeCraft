//
//  SupportView.swift
//  OneNews
//
//  Created by Sok Pich on 1/21/25.
//

import SwiftUI

struct SupportView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var feedbackContent: String = ""
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigation(title: "Support")
            ScrollView {
                VStack(spacing: 10) {
                    TextField("Name *", text: $username)
                        .keyboardType(.twitter)
                        .padding(16)
                        .background(Color.optionBtn1)
                        .cornerRadius(100)
                    TextField("Email *", text: $email)
                        .keyboardType(.twitter)
                        .padding(16)
                        .background(Color.optionBtn1)
                        .cornerRadius(100)
                    TextView(text: $feedbackContent, placeholder: "Feedback content *")
//                        .padding(16)
                        .frame(height: 200)
                        .border(Color.optionBtn1, width: 1)
                        .cornerRadius(15)
                    AuthButton(btnType: .submit)
                }
                .padding(16)
            }
        }
    }
}
