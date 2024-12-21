//
//  Album.swift
//  OneNews
//
//  Created by Sok Pich on 12/16/24.
//
import SwiftUI

struct ContentView: View {
    // Array to store the dates
    var days: [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        var dates: [Date] = []
        
        // Add yesterday's date
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            dates.append(yesterday)
        }
        
        // Add today's date
        dates.append(today)
        
        // Add the next 5 days
        for i in 1...5 {
            if let nextDay = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(nextDay)
            }
        }
        
        return dates
    }
    
    var body: some View {
        List(days, id: \.self) { day in
            HStack {
                Text(dayOfWeek(for: day)) // Show the day of the week
                Spacer()
                Text("\(dayNumber(for: day))") // Show the day number
            }
        }
        .padding()
    }
    
    // Function to get the day of the week in short format
    func dayOfWeek(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E" // "E" gives the abbreviated weekday (e.g., "Wed")
        let dayString = dateFormatter.string(from: date)
        
        switch dayString {
        case "Mon": return "Mon"
        case "Tue": return "Tue"
        case "Wed": return "Wed"
        case "Thu": return "Thu"
        case "Fri": return "Fri"
        case "Sat": return "Sat"
        case "Sun": return "Sun"
        default: return ""
        }
    }
    
    // Function to get the day number (e.g., 18, 19, etc.)
    func dayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
