//
//  ImageCropper.swift
//  LastYear
//
//  Created by Paul Kühnel on 31.12.22.
//

import Foundation
import SwiftUI
import Mantis

struct ImageCropper: UIViewControllerRepresentable {
    @Binding var gotoImageEdit : Bool
    @Binding var image: UIImage?
    @Binding var croppedImage: UIImage?
    @Binding var cropShapeType: Mantis.CropShapeType
    @Binding var presetFixedRatioType: Mantis.PresetFixedRatioType
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: CropViewControllerDelegate {
        func cropViewControllerDidImageTransformed(_ cropViewController: CropViewController) {

        }

        var parent: ImageCropper

        init(_ parent: ImageCropper) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.croppedImage = cropped
            print("transformation is \(transformation)")
            parent.gotoImageEdit = true
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        }

        func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        }

        func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        var config = Mantis.Config()
        config.cropViewConfig.cropShapeType = cropShapeType
        config.presetFixedRatioType = presetFixedRatioType
        let cropViewController = Mantis.cropViewController(image: image!,
                                                           config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {

    }
}
