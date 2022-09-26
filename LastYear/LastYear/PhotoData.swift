//
//  PhotoData.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation
import SwiftUI
import CoreLocation
import Photos

public struct PhotoData: Identifiable, Comparable {
    
    public var id: String
    public var image: Image
    public var date: Date?
    public var location: CLLocation?
    public var isFavorite: Bool
    public var sourceType: PHAssetSourceType
    
    public static func < (lhs: PhotoData, rhs: PhotoData) -> Bool {
        if rhs.isFavorite {
            return true
        } else {
            guard let lhsDate = lhs.date, let rhsDate = rhs.date else { return lhs.isFavorite }
            return lhsDate < rhsDate
        }
    }
    
}
