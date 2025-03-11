//
//  testDownload.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/26/25.
//

import SwiftUI
import UIKit
import Combine
import WebKit
import Photos

struct DownloadView: View {
    @StateObject private var viewModel = FileDownloadViewModel()
    let fileURL = "https://www.pngall.com/wp-content/uploads/5/Pokemon-Pikachu-PNG-Free-Download.png"
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                viewModel.downloadFile(from: fileURL)
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.down.circle")
                    }
                    Text("Download File")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            if let downloadedFileURL = viewModel.downloadedFileURL {
                Button(action: {
                    viewModel.showShareSheet.toggle()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share File")
                    }
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let fileURL = viewModel.downloadedFileURL {
                ShareFileView(fileURL: fileURL)
                    .presentationDetents([.medium, .large])  // Half-screen and full-screen
                    .presentationDragIndicator(.visible)
            }
        }

    }
}

class FileDownloadViewModel: ObservableObject {
    @Published var downloadedFileURL: URL?
    @Published var isLoading = false
    @Published var showShareSheet = false

    func downloadFile(from urlString: String) {
        isLoading = true
        FileDownloader.shared.downloadFile(urlString: urlString) { [weak self] url, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let url = url {
                    self?.downloadedFileURL = url
                    self?.showShareSheet = true
                }
            }
        }
    }
}

struct FilePreviewView: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])

        webView.load(URLRequest(url: fileURL))
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ShareFileView: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

func saveImageToGallery(from url: URL) {
    guard let image = UIImage(contentsOfFile: url.path) else { return }
    
    PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

final class FileDownloader {
    static let shared = FileDownloader()
    
    func downloadFile(urlString: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0))
            return
        }
        
        let destinationURL = FileManagerHelper.shared.getDestinationURL(for: url)
        
        // Check if file already exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            completion(destinationURL, nil)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let tempURL = tempURL, error == nil {
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    completion(destinationURL, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
final class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    func getDestinationURL(for url: URL) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(url.lastPathComponent)
    }
    
    func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
