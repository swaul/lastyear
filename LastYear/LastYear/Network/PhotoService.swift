//
//  PhotoService.swift
//  LastYear
//
//  Created by Paul Kühnel on 22.11.22.
//

import Foundation

public class PhotoService: NSObject, ObservableObject {
    @Published var todaysPhotos: Int = 0
    
    public static let shared = PhotoService()
    
}
