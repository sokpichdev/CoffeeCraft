//
//  String.swift
//  OneNews
//
//  Created by Sok Pich on 1/4/25.
//
import SwiftUI


extension String {
    func convertStringToListOfStrings() -> [String] {
        // Split the string by commas and trim whitespaces
        let numberStrings = self.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return numberStrings
    }
    func convertStringToConcatenatedString() -> String {
        // Remove commas and trim whitespaces, then concatenate the numbers into a single string
        let concatenatedString = self.replacingOccurrences(of: ",", with: "")
        return concatenatedString
    }
    func convertconcatedStrToListOfStr() -> [String] {
        return self.convertStringToConcatenatedString().convertStringToListOfStrings()
    }
    func formatDetailDate(from input: String, type dateType: DateFormatType) -> String? {
        // Define the input date format
        let inputDateFormat = "yyyy-MM-dd HH:mm:ss"
        var outputDateFormat: String

        switch dateType {
        case .day:
            outputDateFormat = "EEEE"
        case .longDateTime:
            outputDateFormat = "dd MMMM yyyy, hh:mm a"
        case .longDateDayTime:
            outputDateFormat = "dd MMMM yyyy, EEE hh:mm a"
        }

        // Create a DateFormatter for parsing the input date string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing

        // Parse the input date string
        guard let date = inputFormatter.date(from: input) else {
            return nil
        }

        // Create a DateFormatter for formatting the output
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputDateFormat
        outputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting

        // Format the date into the desired output format
        return outputFormatter.string(from: date)
    }
    
    
}

enum DateFormatType {
    case day
    case longDateTime
    case longDateDayTime
}
