//
//  PhotosViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import Foundation
import Photos
import AVFoundation
import CoreData
import SwiftUI

public class PhotosViewModel: ObservableObject {
    
    @Published var allPhotos = [PhotoData]()

    init() {
        getAllPhotos()
    }
    
    func getAllPhotos() {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        guard let lastYear = lastYear, allPhotos.isEmpty else { return }
                
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        fetchOptions.predicate = NSPredicate(format: "creationDate = %@", lastYear as NSDate)
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
//                let size = CGSize(width: 700, height: 700) //You can change size here
                manager.requestImage(for: asset, targetSize: .zero, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    if let image = image {
                        let photo = PhotoData(id: asset.localIdentifier, image: Image(uiImage: image), date: asset.creationDate, location: asset.location, isFavorite: asset.isFavorite, sourceType: asset.sourceType)
                        if let date = asset.creationDate, self.isSameDay(date1: date, date2: lastYear) {
                            self.allPhotos.append(photo)
                        }
                    } else {
                        print("error asset to image")
                    }
                }
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            print("No photos to display for ", formatter.string(from: lastYear))
        }
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
}
