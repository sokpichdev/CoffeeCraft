//
//  CodeDetectorView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/18/25.
//

import SwiftUI
import Vision
import PhotosUI

struct CodeDetectorView: View {
    @State private var selectedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var detectedLanguage: String = ""
    @State private var isShowingImagePicker = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
            }
            
            if !detectedLanguage.isEmpty {
                Text("Detected Language: \(detectedLanguage)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ScrollView {
                Text(recognizedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 150)
            
            HStack {
                Button("Take Photo") {
                    isShowingImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            CodeImagePicker(image: $selectedImage, onImagePicked: analyzeImage)
        }
        .padding()
    }
    
    private func analyzeImage(_ image: UIImage) {
        recognizeText(from: image) { text in
            self.recognizedText = text
            self.detectedLanguage = detectProgrammingLanguage(from: text)
        }
    }
    
    private func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("Failed to load image.")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("No text found.")
                return
            }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            completion(recognizedStrings.joined(separator: "\n"))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion("Error recognizing text: \(error.localizedDescription)")
        }
    }
    
    private func detectProgrammingLanguage(from text: String) -> String {
        let keywords = [
            "swift": ["import SwiftUI", "func", "let", "var"],
            "python": ["def ", "import ", "print(", "if __name__"],
            "javascript": ["function", "console.log(", "let ", "const "],
            "java": ["public class", "void main", "System.out.println"],
            "cpp": ["#include", "int main(", "cout <<"],
            "html": ["<!DOCTYPE html>", "<html>", "<head>", "<body>"]
        ]
        
        for (language, patterns) in keywords {
            for pattern in patterns {
                if text.contains(pattern) {
                    return language.capitalized
                }
            }
        }
        
        return "Unknown"
    }
}
