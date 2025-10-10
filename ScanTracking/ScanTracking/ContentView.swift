//
//  ContentView.swift
//  ScanTracking
//
//  Created by Sok Pich on 10/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScanTracking.timestamp, ascending: false)],
        animation: .default)
    private var scans: FetchedResults<ScanTracking>
    
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // MARK: Live Clock
                Text(currentTime, formatter: clockFormatter)
                    .font(.largeTitle)
                    .onReceive(timer) { input in
                        currentTime = input
                    }

                // MARK: Scan Button
                if !hasScannedInToday() {
                    Button(action: { recordScan(type: "IN") }) {
                        Text("Scan In")
                            .font(.title2)
                            .frame(width: 200, height: 60)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else if !hasScannedOutToday() {
                    Button(action: { recordScan(type: "OUT") }) {
                        Text("Scan Out")
                            .font(.title2)
                            .frame(width: 200, height: 60)
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Text("Already scanned today ✅")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                // MARK: Today's Scans List
                List {
                    ForEach(todayScans()) { scan in
                        HStack {
                            Text(scan.type ?? "Unknown")
                                .fontWeight(.bold)
                            Spacer()
                            if let timestamp = scan.timestamp {
                                Text(timestamp, formatter: itemFormatter)
                            }
                        }
                    }
                    .onDelete(perform: deleteScans)
                }

            }
            .padding()
            .navigationTitle("Scan Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    // MARK: Helpers
    private func recordScan(type: String) {
        let newScan = ScanTracking(context: viewContext)
        newScan.id = UUID()
        newScan.type = type
        newScan.timestamp = Date()

        do {
            try viewContext.save()
            if let timestamp = newScan.timestamp {
                let formattedTime = itemFormatter.string(from: timestamp)
                TelegramNotifier.send(message: "\(type) scanned at \(formattedTime)")
            }

        } catch {
            print("Failed to save scan: \(error)")
        }
    }

    private func deleteScans(offsets: IndexSet) {
        offsets.map { scans[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete scan: \(error)")
        }
    }

    private func hasScannedInToday() -> Bool {
        todayScans().contains { $0.type == "IN" }
    }

    private func hasScannedOutToday() -> Bool {
        todayScans().contains { $0.type == "OUT" }
    }

    private func todayScans() -> [ScanTracking] {
        let calendar = Calendar.current
        return scans.filter {
            if let timestamp = $0.timestamp {
                return calendar.isDateInToday(timestamp)
            }
            return false
        }
    }
}

// MARK: Date Formatters
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    formatter.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") // Cambodia time
    return formatter
}()

private let clockFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .none
    formatter.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") // Cambodia time
    return formatter
}()
