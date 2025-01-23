//
//  ContentView.swift
//  PhotoPicker
//
//  Created by Sok Pich on 1/22/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } else {
                Text("No profile picture")
                    .padding()
            }

            Button("Change Profile Picture") {
                showActionSheet.toggle()
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Choose option"),
                    buttons: [
                        .default(Text("Gallery")) {
                            // Check if the app is running on iOS 16+ to use PhotosPicker
                            if #available(iOS 16.0, *) {
                                showImagePicker.toggle()
                            } else {
                                showImagePicker.toggle() // Fallback to UIImagePickerController
                            }
                        },
                        .default(Text("Camera")) {
                            // Check if the camera is available before showing the picker
                            if isCameraAvailable {
                                showCameraPicker.toggle()
                            } else {
                                print("Camera not available")
                            }
                        },
                        .cancel()
                    ]
                )
            }
            .padding()

            // Photo Picker (for iOS 16+)
            if #available(iOS 16.0, *) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select a Photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset
                            if let selectedItem = selectedItem {
                                if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(isPresented: $showCameraPicker, selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showImagePicker) {
            // Show gallery picker for iOS 15 or earlier
            ImagePicker(isPresented: $showImagePicker, selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
    }
}

struct ImagePicker: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    var body: some View {
        ImagePickerController(isPresented: $isPresented, selectedImage: $selectedImage, sourceType: sourceType)
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, selectedImage: $selectedImage)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isPresented: Bool
        @Binding var selectedImage: UIImage?

        init(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>) {
            _isPresented = isPresented
            _selectedImage = selectedImage
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            isPresented = false
        }
    }
}


#Preview {
    ContentView()
}
