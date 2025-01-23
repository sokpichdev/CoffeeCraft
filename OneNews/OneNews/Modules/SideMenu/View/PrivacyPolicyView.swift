//
//  PrivacyPolicyView.swift
//  OneNews
//
//  Created by Sok Pich on 1/21/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigation(title: "Privacy Policy")
            ScrollView {
                Text("Privacy Policy")
            }
        }
    }
}
