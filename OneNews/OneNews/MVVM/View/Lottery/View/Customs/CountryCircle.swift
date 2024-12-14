//
//  CountryCircle.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct CountryCircle: View {
    var countryName: String = ""
    var body: some View {
        Circle()
            .frame(width: 40, height: 40)
            .overlay(
                Image(countryName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            )
    }
}
