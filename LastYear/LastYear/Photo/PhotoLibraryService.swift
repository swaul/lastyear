//
//  PhotoLibraryService.swift
//  LastYear
//
//  Created by Paul Kühnel on 12.11.22.
//

import Foundation
import Photos
import UIKit

public class PhotoLibraryService: ObservableObject {
        
    var imageCachingManager = PHCachingImageManager()
    @Published var results = PHFetchResult<PHAsset>()
    @Published var allPhotos = [PhotoData]()
    @Published var countFound = 0
    
    @Published var formattedDateOneYearAgo: String = ""
    @Published var dateOneYearAgo: Date? {
        didSet {
            guard let dateOneYearAgo else { return }
            formattedDateOneYearAgo = Formatters.dateFormatter.string(from: dateOneYearAgo)
        }
    }
    
    static let shared = PhotoLibraryService()
    
    func fetchImage(
        byLocalIdentifier localId: String,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default
    ) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(
            withLocalIdentifiers: [localId],
            options: nil
        )
        guard let asset = results.firstObject else {
            return nil
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            /// Use the imageCachingManager to fetch the image
            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options,
                resultHandler: { image, info in
                    /// image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
}
