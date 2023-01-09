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
        options.isSynchronous = false
        
        print("done with sudoku", localId)
        
        return try? await imageCachingManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options)
        
//        return try await withCheckedThrowingContinuation { [weak self] continuation in
//            /// Use the imageCachingManager to fetch the image
//            imageCachingManager.requestImage(
//                for: asset,
//                targetSize: targetSize,
//                contentMode: contentMode,
//                options: options,
//                resultHandler: { image, info in
//                    /// image is of type UIImage
//                    if let error = info?[PHImageErrorKey] as? Error {
//                        continuation.resume(throwing: error)
//                        return error
//                    }
//                    continuation.resume(returning: image)
//                    return image
//                }
//            )
//        }
    }
}

extension PHImageManager {
    func requestImage(
        for asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions?
    ) async throws -> UIImage {
        options?.isSynchronous = false

        var requestID: PHImageRequestID?

        return try await withTaskCancellationHandler(
            handler: { [requestID] in
                guard let requestID = requestID else {
                    return
                }

                cancelImageRequest(requestID)
            }
        ) {
            try await withCheckedThrowingContinuation { continuation in
                requestID = requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: contentMode,
                    options: options
                ) { image, info in
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard !(info?[PHImageCancelledKey] as? Bool ?? false) else {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    // When degraded image is provided, the completion handler will be called again.
                    guard !(info?[PHImageResultIsDegradedKey] as? Bool ?? false) else {
                        print("Preview")
                        return
                    }

                    guard let image = image else {
                        // This should in theory not happen.
                        continuation.resume(throwing: UnexpectedNilError())
                        return
                    }

                    // According to the docs, the image is guaranteed at this point.
                    continuation.resume(returning: image)
                }
            }
        }
    }
}

struct UnexpectedNilError: Error {}
