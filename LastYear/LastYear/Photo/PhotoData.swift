//
//  PhotoData.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation
import SwiftUI
import CoreLocation
import UIKit
import Photos

public enum PhotoType {
    case photo
    case screenshot
    case live
}

public class PhotoData: Identifiable, Comparable, Hashable {
    
    public var id: String
    public var image: Image
    public var uiImage: UIImage
    public var date: Date?
    public var formattedDate: String
    public var location: CLLocation?
    public var isFavorite: Bool
    public var sourceType: PHAssetSourceType
    public var faces: Int
    public var city: String? = nil
    public var postalCode: String? = nil
    public var photoType: PhotoType = .photo
    public var animal: AnimalType = .none
    
    init(id: String, image: UIImage, date: Date? = nil, formattedDate: String, location: CLLocation? = nil, isFavorite: Bool, sourceType: PHAssetSourceType) {
        self.id = id
        self.image = Image(uiImage: image)
        self.date = date
        self.location = location
        self.isFavorite = isFavorite
        self.sourceType = sourceType
        self.formattedDate = formattedDate
        self.uiImage = image.addWatermark(text: formattedDate)
        let ciImage = CIImage(image: image)!
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
        
        let faces = faceDetector.features(in: ciImage)
        self.faces = faces.count
        
        if !faces.isEmpty {
            print("I found \(faces.count) in this image!")
        }
        
        guard let location = location else { return }
        getCity(location: location)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    
    public static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: PhotoData, rhs: PhotoData) -> Bool {
        if lhs.isFavorite == rhs.isFavorite {
            
            guard let lhsDate = lhs.date, let rhsDate = rhs.date else { return lhs.isFavorite }
            return (rhs.faces, lhsDate) < (lhs.faces, rhsDate)
            
        } else {
            return lhs.isFavorite && !rhs.isFavorite
        }
    }
    
    func getCity(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error {
                print(error.localizedDescription)
            } else {
                self.city = placemarks?.first?.locality ?? "No location"
                self.postalCode = placemarks?.first?.postalCode ?? "No zip"
            }
        }
    }
}

public enum AnimalType {
    case cat
    case dog
    case none
}
