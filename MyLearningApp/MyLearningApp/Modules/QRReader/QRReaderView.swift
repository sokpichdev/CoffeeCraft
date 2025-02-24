//
//  QRReaderView.swift
//  QRReader
//
//  Created by Sok Pich on 1/23/25.
//
import SwiftUI
import AVFoundation
import Vision

struct QRReaderView: View {
    
    @State private var scannedString: String = "Find a code to scan"
    @State private var isFlashOn: Bool = false
    @State private var isScanning: Bool = false
    @State private var shouldReset: Bool = false
    @State var scanningFrameView: UIView?
    let captureSession = AVCaptureSession()
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(scannedString: $scannedString, isFlashOn: $isFlashOn, isScanning: $isScanning, shouldReset: $shouldReset, captureSession: captureSession, scanningFrameView: $scanningFrameView)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button(action: {
                    toggleFlash()
                }) {
                    Image(systemName: isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .padding(.bottom, 30)
                
                Text(scannedString)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
        .onChange(of: scannedString) { newValue in
            handleScannedQR(newValue)
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                DispatchQueue.global(qos: .background).async {
                    captureSession.stopRunning()
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                DispatchQueue.global(qos: .background).async {
                    captureSession.startRunning()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }

    }
    func resetScanner() {
        scanningFrameView?.removeFromSuperview() // Remove existing scanning frame if any
        scannedString = "Find a code to scan"
        shouldReset = false
    }

    func handleScannedQR(_ scannedData: String) {
        if let url = URL(string: scannedData), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            
        } else {
            print("Scanned data is not a valid URL")
        }
        resetScreen()
    }
    
    func resetScreen() {
        // Reset the scanned string and flashlight state
        scannedString = "Find a code to scan"
        isFlashOn = false
        shouldReset = true
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
}
