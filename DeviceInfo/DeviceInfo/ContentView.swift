//
//  ContentView.swift
//  DeviceInfo
//
//  Created by Sok Pich on 5/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("📱 Device Information")
                .font(.title)
                .bold()
            
            InfoRow(label: "Device Name", value: UIDevice.current.name)
            InfoRow(label: "System Name", value: UIDevice.current.systemName)
            InfoRow(label: "System Version", value: UIDevice.current.systemVersion)
            InfoRow(label: "Model", value: UIDevice.current.model)
            InfoRow(label: "Localized Model", value: UIDevice.current.localizedModel)
        }
        .padding()
    }
}

struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}
