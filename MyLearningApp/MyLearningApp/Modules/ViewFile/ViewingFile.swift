//
//  ViewingFile.swift
//  MyLearningApp
//
//  Created by Sok Pich on 3/14/25.
//

import SwiftUI

class FilesViewModel: ObservableObject {
    @Published var files: [String] = []
    
    private let fileManager = FileManager.default
    private let documentsURL: URL
    
    init() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadFiles()
    }
    
    func loadFiles() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            files = fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
    
    func createFile(named fileName: String, withContent content: String) {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        let data = content.data(using: .utf8)
        
        do {
            try data?.write(to: fileURL)
            print("File created successfully")
            loadFiles() // Refresh the list
        } catch {
            print("Error creating file: \(error.localizedDescription)")
        }
    }
    
    func deleteFile(named fileName: String) {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("File deleted successfully")
            loadFiles() // Refresh the list
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    func updateFile(named fileName: String, withContent content: String) {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        let data = content.data(using: .utf8)
        
        do {
            try data?.write(to: fileURL)
            print("File updated successfully")
            loadFiles() // Refresh the list
        } catch {
            print("Error updating file: \(error.localizedDescription)")
        }
    }
}
struct ViewingFile: View {
    @StateObject private var viewModel = FilesViewModel()
    @State private var newFileName: String = ""
    @State private var fileContent: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.files, id: \.self) { file in
                    Text(file)
                }
                
                HStack {
                    TextField("File name", text: $newFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Create File") {
                        viewModel.createFile(named: newFileName, withContent: fileContent)
                    }
                    .padding()
                }
                
                HStack {
                    TextField("File content", text: $fileContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Update File") {
                        viewModel.updateFile(named: newFileName, withContent: fileContent)
                    }
                    .padding()
                }
                
                Button("Delete File") {
                    viewModel.deleteFile(named: newFileName)
                }
                .padding()
                
            }
            .navigationTitle("File Manager")
        }
    }
}
