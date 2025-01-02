//
//  SummaryView.swift
//  OneNews
//
//  Created by Sok Pich on 12/10/24.
//
import SwiftUI

struct SummaryView: View {
    @ObservedObject var mDVM: MatchDetailViewModel

    var body: some View {
        if let events = mDVM.mDVM.events, !events.isEmpty {
            VStack(spacing: 0) {
                ForEach(events, id: \.value) { event in
                    let (minutes, description) = parseSummaryData(data: event.value ?? "")
                    SummaryDetail(minutes: minutes, description: description)
                    Divider().padding(.horizontal, 16)
                }
            }
            .background(Color.optionBtn1)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.letters.opacity(0.2), lineWidth: 3))
            .cornerRadius(10)
            .padding(10)
            .background(Color.optionBtn1)
            .cornerRadius(10)
            .padding(16)
        } else {
            NoDataView()
        }
    }

    /// Parses the input `value` and splits it into minutes and description
    func parseSummaryData(data: String) -> (String, String) {
        if let range = data.range(of: "' - ") {
            let minutes = String(data[..<range.lowerBound]).trimmingCharacters(in: .whitespaces) + "'"
            var description = String(data[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            
            // Remove leading `-` if present in description
            if description.first == "-" {
                description.removeFirst()
            }
            
            return (minutes, description.trimmingCharacters(in: .whitespaces))
        } else {
            // If no "' - " pattern, treat the entire string as description
            return ("", data)
        }
    }
}

struct SummaryDetail: View {
    var minutes: String
    var description: String

    var body: some View {
        HStack(alignment: .top) { // for better handling of multiline text
            Text(minutes.isEmpty ? " " : minutes) // Display minutes or placeholder
                .frame(maxWidth: 70, alignment: .center)
                .foregroundColor(.letters)
                .multilineTextAlignment(.center)

            Text(description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .background(Color.optionBtn1)
        }
        .font(.caption2)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
