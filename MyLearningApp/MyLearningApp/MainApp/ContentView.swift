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
    @State private var selectedDropdownOption: Int? = nil
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
//                        CustomModuleButton(name: "📷 QR Reader", color: .blue) {
//                            selectButton(.qrReader)
//                        }
                        
                        CustomModuleButton(name: "📦 Drag & Drop", color: .green) {
                            selectButton(.dragdrop)
                        }
                        CustomModuleButton(name: "Dual Scrolls", color: .blue) {
                            selectButton(.dualScroll)
                        }
//
//                        CustomModuleButton(name: "🔍 Code Detector", color: .purple) {
//                            selectButton(.codeDetector)
//                        }
//                        
//                        CustomModuleButton(name: "Video Streaming", color: .yellow) {
//                            selectButton(.videoStreaming)
//                        }
//                        
                        Menu {
                            Button("Fixed Scrolling View") { selectDropdownOption(1) }
                            Button("Gesture Scrolling View - Volume Slider") { selectDropdownOption(2) }
                        } label: {
                            CustomModuleButton(name: "Scrolling Options", color: .blue) { }
                        }
//                        CustomModuleButton(name: "Download", color: .green) {
//                            selectButton(.download)
//                        }
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
    
    private func selectDropdownOption(_ option: Int) {
        selectedDropdownOption = option
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
        case .videoStreaming:
            VideoStreamingView()
        case .scrolling:
            FixedScrollingView()
        case .download:
            DownloadView()
        case .map:
            MapView()
        case .timeZone:
            TimeZoneView()
        case .viewFile:
            ViewingFile()
        case .dualScroll:
            DualScrollView()
        case .none:
            EmptyView()
        }
        if let option = selectedDropdownOption {
            if option == 1 {
                FixedScrollingView()
            } else if option == 2 {
                ScrollingViewWithSliderView()
            }
        }
    }
}

// MARK: - Enum for Button Type
enum Buttontype {
    case qrReader
    case dragdrop
    case codeDetector
    case videoStreaming
    case scrolling
    case download
    case map
    case timeZone
    case viewFile
    case dualScroll
    case none
}
