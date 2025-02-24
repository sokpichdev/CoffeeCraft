//
//  ScannerView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/10/25.
//
import SwiftUI
import AVFoundation
import Vision

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedString: String
    @Binding var isFlashOn: Bool
    @Binding var isScanning: Bool
    @Binding var shouldReset: Bool
    
    let captureSession: AVCaptureSession
    let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    @Binding var scanningFrameView: UIView? // State for scanning frame
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return viewController }

        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.frame = viewController.view.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(videoPreviewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Toggle flash
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            try? device.lockForConfiguration()
            if isFlashOn {
                try? device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        }
        
        // Show the scanning area effect (zoom-in frame)
        isScanning ? applyScanningFrame(to: uiViewController.view) : nil
    }
    
    func resetScanner(in view: UIView) {
        // Remove existing scanning frame if any
        scanningFrameView?.removeFromSuperview()
        
        // Stop the capture session and reset scanning state
        captureSession.stopRunning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.captureSession.startRunning() // Restart the capture session after a delay
            self.scanningFrameView = nil // Reset scanning frame reference
        }
        
        shouldReset = false
    }
    
    func applyScanningFrame(to view: UIView) {
        guard scanningFrameView == nil else { return } // Only add once
        
        // Create a zoom-in frame on the screen for QR code scanning area
        let frameWidth: CGFloat = 300
        let frameHeight: CGFloat = 300
        let frameX = (view.bounds.width - frameWidth) / 2
        let frameY = (view.bounds.height - frameHeight) / 2
        
        let scanningFrame = UIView(frame: CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight))
        scanningFrame.layer.borderWidth = 4
        scanningFrame.layer.borderColor = UIColor.green.cgColor
        scanningFrame.layer.cornerRadius = 10
        view.addSubview(scanningFrame)
        
        self.scanningFrameView = scanningFrame // Keep reference to the frame
        
        // Animate the zoom-in effect (optional)
        UIView.animate(withDuration: 0.8, animations: {
            scanningFrame.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.8, animations: {
                scanningFrame.transform = CGAffineTransform.identity
            })
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: ScannerView
        private var requests = [VNRequest]()
        
        init(_ parent: ScannerView) {
            self.parent = parent
            super.init()
            setupVision()
        }
        
        private func setupVision() {
            let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
            barcodeRequest.symbologies = [.qr, .ean8, .code39, .aztec]
            self.requests = [barcodeRequest]
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                print("Failed to perform barcode detection: \(error)")
            }
        }
        
        private func handleBarcodes(request: VNRequest, error: Error?) {
            if let error = error {
                print("Barcode detection error: \(error)")
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation] else { return }
            for barcode in results {
                if let payload = barcode.payloadStringValue {
                    Task {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.parent.scannedString = payload
                    }
                    self.parent.captureSession.stopRunning()
                }
            }
        }
    }
}
