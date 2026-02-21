//
//  Date+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/21/26.
//
import SwiftUI

extension Date {
   var relativeFormatted: String {
       let formatter = RelativeDateTimeFormatter()
       formatter.unitsStyle = .short
       return formatter.localizedString(for: self, relativeTo: Date())
   }
}
