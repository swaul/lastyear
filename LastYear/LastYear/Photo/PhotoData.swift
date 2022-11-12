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

public enum PhotoType: Codable {
    case photo
    case screenshot
    case live
}

public class PhotoData: Identifiable, Comparable, Hashable {
    
    public var id: String
    public var date: Date?
    public var formattedDate: String
    public var isFavorite: Bool
    public var sourceType: PHAssetSourceType
    public var assetID: String
//    public var faces: Int
    public var photoType: PhotoType = .photo
    
    init(id: String, assetId: String, date: Date? = nil, formattedDate: String, location: CLLocation? = nil, isFavorite: Bool, sourceType: PHAssetSourceType) {
        self.id = id
        self.assetID = assetId
        self.date = date
        self.isFavorite = isFavorite
        self.sourceType = sourceType
        self.formattedDate = formattedDate
//        self.waterMarkedImage = image.addWatermark(text: formattedDate)
//        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
//
//        let faces = faceDetector.features(in: ciImage)
//        self.faces = faces.count
//
//        if !faces.isEmpty {
//            print("I found \(faces.count) in this image!")
//        }
//
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
            return lhsDate < rhsDate
            
        } else {
            return lhs.isFavorite && !rhs.isFavorite
        }
    }
}

extension PhotoData {
    static var dummy: PhotoData {
        PhotoData(id: "123", assetId: "123", formattedDate: "20.09.2021", isFavorite: false, sourceType: .typeUserLibrary)
    }
}
