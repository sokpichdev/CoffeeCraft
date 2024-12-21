//
//  OptionButtons.swift
//  OneNews
//
//  Created by Sok Pich on 12/19/24.
//

import SwiftUI

struct OptionButtons: View {
//    @Binding var selectedFootball: Bool
    @ObservedObject var sportDateVM: SportDatesViewModel
    
    var body: some View {
        HStack { // buttons
            CustomOptionButtons(
                title: "Football",
                imageName: "Football",
                isSelected: sportDateVM.isSelectedFootball
            ) {
                sportDateVM.isSelectedFootball = true
                print("football")
            }
            
            CustomOptionButtons(
                title: "Basketball",
                imageName: "Basketball",
                isSelected: !sportDateVM.isSelectedFootball
            ) {
                sportDateVM.isSelectedFootball = false
                print("basketball")
            }
            
            Spacer()
        }
        .padding(16)
    }
}
