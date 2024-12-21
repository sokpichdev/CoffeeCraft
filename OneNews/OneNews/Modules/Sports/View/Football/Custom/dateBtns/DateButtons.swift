//
//  DateButtons.swift
//  OneNews
//
//  Created by Sok Pich on 12/19/24.
//

import SwiftUI

struct DateButtons: View {
    
    @ObservedObject var sportDatesVM: SportDatesViewModel
    var body: some View {
        HStack(spacing: 10) {
            if sportDatesVM.isSelectedDate {
                SelectedDateView(sportDateVM: sportDatesVM)
            } else {
                OGLayoutView(sportDateVM: sportDatesVM)
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $sportDatesVM.isDatePickerPresented) {
            DatePickerSheet(sportDateVM: sportDatesVM)
        }
    }
    
    
}
