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

public struct PhotoData: Identifiable, Comparable {
    
    public var id: String
    public var image: Image
    public var date: Date?
    public var location: CLLocation?
    public var isFavorite: Bool
    public var sourceType: PHAssetSourceType
    public var faces: Int
    
    init(id: String, image: UIImage, date: Date? = nil, location: CLLocation? = nil, isFavorite: Bool, sourceType: PHAssetSourceType) {
        self.id = id
        self.image = Image(uiImage: image)
        self.date = date
        self.location = location
        self.isFavorite = isFavorite
        self.sourceType = sourceType
        
        let ciImage = CIImage(image: image)!
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!

        let faces = faceDetector.features(in: ciImage)
        self.faces = faces.count
        if !faces.isEmpty {
            print("I found \(faces.count) in this image!")
        }
    }
    
    public static func < (lhs: PhotoData, rhs: PhotoData) -> Bool {
        if lhs.isFavorite == rhs.isFavorite {
            
            guard let lhsDate = lhs.date, let rhsDate = rhs.date else { return lhs.isFavorite }
            return (rhs.faces, lhsDate) < (lhs.faces, rhsDate)
            
        } else {
            return lhs.isFavorite && !rhs.isFavorite
        }
    }
    
}

extension PHAssetSourceType {
    
}
