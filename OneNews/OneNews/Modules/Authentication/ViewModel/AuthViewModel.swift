//
//  AuthViewModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/25/24.
//

import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmpassword: String = ""
    @Published var isHidePassword: Bool = true
    @Published var otp: String = ""
    @Published var otpEnded: Bool = false
    @Published var timerValue: Int = 20
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timerValue > 0 {
                self.timerValue -= 1
            } else {
                timer.invalidate()
                self.otpEnded = true
            }
        }
    }
}
