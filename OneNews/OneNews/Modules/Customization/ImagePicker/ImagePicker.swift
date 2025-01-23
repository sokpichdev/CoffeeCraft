//
//  ImagePicker.swift
//  OneNews
//
//  Created by Sok Pich on 1/22/25.
//

import SwiftUI
import PhotosUI

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
