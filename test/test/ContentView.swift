//
//  ContentView.swift
//  test
//
//  Created by Sok Pich on 5/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct DeviceSession: Identifiable {
    let id = UUID()
    let name: String
    let platform: String
    let location: String
    let status: String
    let isCurrentDevice: Bool
}

struct LinkedDevicesView: View {
    @State private var sessions: [DeviceSession] = [
        DeviceSession(name: "iPhone 13 Pro Max", platform: "Telegram iOS 11.11.1", location: "Phnom Penh, Cambodia", status: "online", isCurrentDevice: true),
        DeviceSession(name: "iMac M1", platform: "Telegram macOS 11.6 APP_STORE", location: "Phnom Penh, Cambodia", status: "1 hour ago", isCurrentDevice: false),
        DeviceSession(name: "MacBook Pro", platform: "Telegram macOS 10.9.1 APP_STORE", location: "Phnom Penh, Cambodia", status: "yesterday at 23:13", isCurrentDevice: false),
        DeviceSession(name: "G713RC", platform: "Telegram Desktop 5.14.2 x64", location: "Phnom Penh, Cambodia", status: "18/05/25", isCurrentDevice: false),
        DeviceSession(name: "Oppo F11", platform: "Telegram Android 11.4.3", location: "Phnom Penh, Cambodia", status: "14/12/24", isCurrentDevice: false),
    ]
    @State private var isEditing = false
    @State private var showAutoTerminateSheet = false
    @State private var autoTerminateOption: String = "1 month"

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "iphone.gen3")
                            .resizable()
                            .frame(width: 24, height: 40)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Link Telegram Desktop")
                                .font(.headline)
                            Text("Scan a QR code to link device")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("This Device"), footer: Text("Logs out all devices except for this one.")) {
                    if let currentDevice = sessions.first(where: { $0.isCurrentDevice }) {
                        DeviceRow(session: currentDevice)
                    }

                    Button(action: {
                        sessions.removeAll(where: { !$0.isCurrentDevice })
                    }) {
                        Text("Terminate all other sessions")
                            .foregroundColor(.red)
                    }
                }
                
                Section(
                    header: Text("Active Sessions"),
                    footer: Text("This official Telegram app is available for iPhone, iPad, Android, and Windows, macOS and Linux. Learn More")
                ) {
                    ForEach(sessions.filter { !$0.isCurrentDevice }) { session in
                        HStack {
                            if isEditing {
                                Button(action: {
                                    if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                        sessions.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            DeviceRow(session: session)
                            Spacer()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                    sessions.remove(at: index)
                                }
                            } label: {
                                Label("Terminate", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Section(header: Text("AUTOMATICALLY TERMINATE OLD SESSIONS")) {
                    Button(action: {
                        showAutoTerminateSheet = true
                    }) {
                        HStack {
                            Text("If inactive for")
                            Spacer()
                            Text(autoTerminateOption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAutoTerminateSheet) {
            AutoTerminateSheet(selectedOption: $autoTerminateOption)
                .presentationDetents([.fraction(0.3), .medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct DeviceRow: View {
    let session: DeviceSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.name)
                .font(.headline)
            Text(session.platform)
                .font(.subheadline)
            Text("\(session.location) • \(session.status)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct AutoTerminateSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedOption: String
    let options = ["1 week", "2 weeks", "1 month", "3 months", "Never"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selectedOption {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOption = option
                        dismiss()
                    }
                }
            }
        }
    }
}
