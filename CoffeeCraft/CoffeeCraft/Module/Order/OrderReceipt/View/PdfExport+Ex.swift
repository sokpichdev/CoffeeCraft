//
//  PdfExport+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/27/26.
//
import SwiftUI
import PDFKit

// MARK: - PDF Export Extension
extension View {
    func exportToPDF(filename: String, completion: @escaping (URL?) -> Void) {
        let controller = UIHostingController(
            rootView: self.drawingGroup(opaque: false, colorMode: .extendedLinear)
        )
        
        let view = controller.view!
        view.bounds = CGRect(origin: .zero, size: CGSize(width: 380, height: 2000))
        view.backgroundColor = .clear
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let targetSize = view.sizeThatFits(
                CGSize(width: 380, height: UIView.layoutFittingExpandedSize.height)
            )
            
            view.bounds = CGRect(origin: .zero, size: targetSize)
            view.layoutIfNeeded()
            
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = [
                kCGPDFContextCreator as String: "CoffeeCraft",
                kCGPDFContextTitle as String: filename
            ]
            
            let renderer = UIGraphicsPDFRenderer(
                bounds: CGRect(origin: .zero, size: targetSize),
                format: format
            )
            
            let data = renderer.pdfData { context in
                context.beginPage()
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(filename).pdf")
            
            do {
                try data.write(to: url)
                completion(url)
            } catch {
                print("PDF save error: \(error)")
                completion(nil)
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
