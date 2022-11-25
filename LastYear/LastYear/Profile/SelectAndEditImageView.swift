//
//  SelectAndEditImageView.swift
//  LastYear
//
//  Created by Paul Kühnel on 18.11.22.
//

import SwiftUI
import ImageCropper

struct SelectAndEditImageView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State var image: UIImage
    
    @Binding var resultImage: UIImage?
    @State var selectedImage: UIImage? = nil
    
    @State var cropShowing = false
    
    var body: some View {
        if selectedImage == nil {
            ImagePicker(selectedImage: $selectedImage)
        } else {
            ImageCropperView(image: Image("stock"),
                             cropRect: nil,
                             ratio: CropperRatio(width: 1, height: 1))
            .onCropChanged { (newCrop) in
              print(newCrop)
            }
        }
    }
}

