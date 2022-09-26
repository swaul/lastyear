//
//  PhotoData.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation
import SwiftUI
import CoreLocation

public struct PhotoData: Identifiable {
    public var id: String
    public var image: Image
    public var date: Date?
    public var location: CLLocation?
}
