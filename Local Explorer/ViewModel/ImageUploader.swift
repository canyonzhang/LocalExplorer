//
//  ImageUploader.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/28/23.
//

import PhotosUI
import SwiftUI

// Define a SwiftUI view that represents a UIImagePickerController
struct ImageUploader: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    // Helper class to manage interactions between SwiftUI and UIKit
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        var parent: ImageUploader
        
        init(_ parent: ImageUploader){
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // Check if there are any results and if the first one contains an UIImage
            guard let provider = results.first?.itemProvider else {return}
            if provider.canLoadObject(ofClass: UIImage.self){
                // Load the UIImage from the provider and assign it to the parent's image property
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
    // Method to create and configures the PHPickerViewController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        // Set the delegate to the Coordinator instance to handle the image selection
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
