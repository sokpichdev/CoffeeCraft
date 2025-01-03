//
//  Dates.swift
//  OneNews
//
//  Created by Sok Pich on 12/19/24.
//
import SwiftUI

extension Date {
    func formattedAsDateOnly() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    func getDayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
}
