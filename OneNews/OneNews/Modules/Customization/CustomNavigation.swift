//
//  CustomNavigation.swift
//  OneNews
//
//  Created by Sok Pich on 12/31/24.
//

import SwiftUI

extension View {
    public func customNav(title: String = "", tintColor: Color = .primary) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomNavigation(title: title, tintColor: tintColor)
            )
    }
}

struct CustomNavigation: View {
    var title: String = ""
    var tintColor: Color = .letters

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            backButton
            Spacer()
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        Divider()
    }
}

extension CustomNavigation {
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
        })
        .foregroundStyle(tintColor)
    }
}

