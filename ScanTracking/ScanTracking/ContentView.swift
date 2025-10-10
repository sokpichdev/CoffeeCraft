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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                HStack(spacing: 40) {
                    Button(action: { recordScan(type: "IN") }) {
                        Text("Scan In")
                            .font(.title2)
                            .frame(width: 120, height: 50)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { recordScan(type: "OUT") }) {
                        Text("Scan Out")
                            .font(.title2)
                            .frame(width: 120, height: 50)
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top)

                List {
                    ForEach(scans) { scan in
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
            .navigationTitle("Scan Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func recordScan(type: String) {
        let newScan = ScanTracking(context: viewContext)
        newScan.id = UUID()
        newScan.type = type
        newScan.timestamp = Date()

        do {
            try viewContext.save()
            
            // Send Telegram notification
            TelegramNotifier.send(message: "\(type) scanned at \(newScan.timestamp!)")
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
