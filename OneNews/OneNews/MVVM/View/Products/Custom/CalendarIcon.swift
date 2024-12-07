//
//  CustomSmallImage.swift
//  OneNews
//
//  Created by Sok Pich on 12/7/24.
//

import SwiftUI

struct CalendarIcon: View {
    var body: some View {
        Image(systemName: "calendar")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(.black)
    }
}
