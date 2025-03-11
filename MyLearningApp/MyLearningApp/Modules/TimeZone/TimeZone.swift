//
//  TimeZone.swift
//  MyLearningApp
//
//  Created by Sok Pich on 3/11/25.
//

import SwiftUI

struct TimeZoneView: View {
    @StateObject var timeZoneVM = TimeZoneViewModel()
    
    // List of date-time format options
    let dateFormats = ["Full Date Time", "Time (HH:mm:ss)", "Month and Year (MM, yyyy)", "dd-MMM-yyyy", "dd MMM, yyyy", "yyyy-MM-dd"]
    
    // List of available timezones
    let timeZones = ["Asia/Phnom_Penh", "UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"]
    
    @State private var selectedFormat = "Full Date Time"
    @State private var selectedTimeZone = "Asia/Phnom_Penh"
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Select Date-Time Format and Timezone")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 30)
            
            // Date Format Picker
            VStack {
                Text("Date Format")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Picker("Select Date Format", selection: $selectedFormat) {
                    ForEach(dateFormats, id: \.self) { format in
                        Text(format)
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                .padding(.horizontal)
            }
            
            // Timezone Picker
            VStack {
                Text("Timezone")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Picker("Select Timezone", selection: $selectedTimeZone) {
                    ForEach(timeZones, id: \.self) { zone in
                        Text(zone)
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                .padding(.horizontal)
            }
            
            // Displaying the current date-time in the selected format and timezone
            VStack(alignment: .leading) {
                Text("Current Timezone: \(selectedTimeZone)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .padding(.horizontal)
                
                Text("Formatted Date/Time:")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                Text(timeZoneVM.getFormattedDateTime(format: selectedFormat, timeZone: selectedTimeZone))
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal, 15)
        .onAppear {
            timeZoneVM.startTimer()
        }
        .onDisappear {
            timeZoneVM.stopTimer()
        }
    }
}

class TimeZoneViewModel: ObservableObject {
    @Published var currentTime: String = ""
    @Published var timer: Timer?
    
    func startTimer() {
        if timer != nil {
            return
        }
        
        timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTime()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        print("Stop Timer ------")
    }
    
    func updateTime() {
        DispatchQueue.main.async {
            self.currentTime = self.getFormattedDateTime(format: "Full Date Time", timeZone: "Asia/Phnom_Penh")
//            print("Updated Time:", self.currentTime)
        }
    }
    
    // Get formatted date and time with chosen format and timezone
    func getFormattedDateTime(format: String, timeZone: String) -> String {
        let formatter = DateFormatter()
        
        switch format {
        case "Full Date Time":
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        case "Time (HH:mm:ss)":
            formatter.dateFormat = "HH:mm:ss"
        case "Month and Year (MM, yyyy)":
            formatter.dateFormat = "MM, yyyy"
        case "dd-MMM-yyyy":
            formatter.dateFormat = "dd-MMM-yyyy"
        case "dd MMM, yyyy":
            formatter.dateFormat = "dd MMM, yyyy"
        case "yyyy-MM-dd":
            formatter.dateFormat = "yyyy-MM-dd"
        default:
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        }
        
        // Set the chosen timezone
        formatter.timeZone = TimeZone(identifier: timeZone)
        
        return formatter.string(from: Date())
    }
}


extension String {
    func formatDateddMMyyyy(option: Int) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        guard let date = inputFormatter.date(from: self) else {
            return "Invalid Date"
        }
        
        let outputFormatter = DateFormatter()
        if option == 1 {
            outputFormatter.dateFormat = "dd-MMM-yyyy"
        } else if option == 2 {
            outputFormatter.dateFormat = "dd MMM, yyyy"
        } else if option == 3 {
            outputFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        return outputFormatter.string(from: date)
    }
    
    func formatMMMyyyy() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM, yyyy"
        return formatter.string(from: Date())
    }
    
    // Format time as hour, minute, and second
    func formatHourMinuteSecond() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        guard let date = inputFormatter.date(from: self) else {
            return "Invalid Time"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm:ss" // Format as hour, minute, second
        return outputFormatter.string(from: date)
    }
}
