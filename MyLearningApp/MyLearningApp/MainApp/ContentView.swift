//
//  ContentView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/10/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var isNavigated: Bool = false
    @State private var selectedButton: Buttontype = .none
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack {
                Text("My Learning App")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Text("Explore various features below")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 15) {
                        CustomModuleButton(name: "📷 QR Reader", color: .blue) {
                            selectButton(.qrReader)
                        }
                        
                        CustomModuleButton(name: "📦 Drag & Drop", color: .green) {
                            selectButton(.dragdrop)
                        }
                        
                        CustomModuleButton(name: "🔍 Code Detector", color: .purple) {
                            selectButton(.codeDetector)
                        }
                        
                        CustomModuleButton(name: "👥 Employee Hierarchy", color: .orange) {
                            selectButton(.employee)
                        }
                        CustomModuleButton(name: "Video Streaming", color: .yellow) {
                            selectButton(.videoStreaming)
                        }
                        CustomModuleButton(name: "Scrolling", color: .yellow) {
                            selectButton(.scrolling)
                        }
                        CustomModuleButton(name: "Download", color: .green) {
                            selectButton(.download)
                        }
                        CustomModuleButton(name: "Map", color: .purple) {
                            selectButton(.map)
                        }
                        CustomModuleButton(name: "Time Zone", color: .orange) {
                            selectButton(.timeZone)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationDestination(isPresented: $isNavigated) {
                destinationView()
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }
    
    /// Handles button selection
    private func selectButton(_ type: Buttontype) {
        selectedButton = type
        isNavigated = true
    }
    
    /// Determines the destination view
    @ViewBuilder
    private func destinationView() -> some View {
        switch selectedButton {
        case .qrReader:
            QRReaderView()
        case .dragdrop:
            DragDropView()
        case .codeDetector:
            CodeDetectorView()
        case .employee:
            ReportingHierarchyView()
        case .videoStreaming:
            VideoStreamingView()
        case .scrolling:
            ScrollingView()
        case .download:
            DownloadView()
        case .map:
            MapView()
        case .timeZone:
            TimeZoneView()
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Enum for Button Type
enum Buttontype {
    case qrReader
    case dragdrop
    case codeDetector
    case employee
    case videoStreaming
    case scrolling
    case download
    case map
    case timeZone
    case none
}



