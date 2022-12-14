//
//  PhotosViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import Foundation
import Photos
import CoreData
import SwiftUI
import Combine
import WidgetKit

public class PhotosViewModel: ObservableObject {
    
    @Published var formattedDateOneYearAgo: String = ""
    @Published var bestImage: PhotoData?
    @Published var countFound: Int? = nil
    @Published var requestsFailed = 0
    @Published var dateOneYearAgo: Date? {
        didSet {
            guard let dateOneYearAgo else { return }
            formattedDateOneYearAgo = Formatters.dateFormatter.string(from: dateOneYearAgo)
        }
    }
    @Published var allPhotos = [PhotoData]()
    
    var imageCachingManager = PHCachingImageManager()
    
    @ObservedObject var authService = AuthService.shared
    
    var cancellabels = Set<AnyCancellable>()
    
    init() {
        dateOneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        removeOld()
    }
    
    func removeOld() {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.value(forKey: userDefaultsPhotosKey) as? Data {
                let decoded = try! JSONDecoder().decode([String].self, from: data)
                
                print(decoded)
            }
        }
    }
    
    func load() {
        Helper.removeAll()
        
        setupBinding()
        getAllPhotos()
    }
    
    func reset() {
        allPhotos.removeAll()
        bestImage = nil
        countFound = nil
    }
    
    func setupBinding() {
        authService.$loggedIn.sink { [weak self] isLoggedIn in
            if !isLoggedIn {
                self?.reset()
            }
        }.store(in: &cancellabels)
        
        $allPhotos.sink { [weak self] data in
            guard let countFound = self?.countFound else { return }
            print("Found: \(countFound) allPhotos: \(data.count)")
            if countFound == data.count {
                self?.fetchAndSafeImages()
            }
        }.store(in: &cancellabels)
    }
    
    func reloadPhotos() {
        dateOneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        allPhotos.removeAll()
        getAllPhotos()
    }
    
    func getAllPhotos() {
        guard let lastYear = dateOneYearAgo else {
            return
        }
        
        countFound = nil
        
        let oneBeforeLastYear = Calendar.current.date(byAdding: .day, value: -1, to: lastYear)!.endOfDay
        let oneAfterLastYear = Calendar.current.date(byAdding: .day, value: 1, to: lastYear)!.startOfDay
        
        imageCachingManager.allowsCachingHighQualityImages = false
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", oneBeforeLastYear as NSDate, oneAfterLastYear as NSDate)
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        countFound = results.countOfAssets(with: .image)

        print("Images found:", countFound!)
        
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                if !asset.isHidden {
                    let photo = PhotoData(id: self.makeID(id: asset.localIdentifier), assetId: asset.localIdentifier, date: asset.creationDate, formattedDate: self.formattedDateOneYearAgo, location: asset.location, isFavorite: asset.isFavorite, sourceType: asset.sourceType)
                    
                    if let date = asset.creationDate, self.isSameDay(date1: date, date2: lastYear) {
                        if asset.mediaSubtypes == .photoScreenshot {
                            photo.photoType = .screenshot
                            self.allPhotos.append(photo)
                        } else {
                            photo.photoType = .photo
                            self.allPhotos.append(photo)
                        }
                    } else {
                        self.countFound! -= 1
                        self.requestsFailed += 1
                        print("error asset to image ", asset.mediaSubtypes)
                    }
                }
            }
        } else {
            print("No photos to display for ", Formatters.dateFormatter.string(from: lastYear))
        }
    }
    
    func fetchAndSafeImages() {
        Task {
            for asset in allPhotos {
                if let image = try await PhotoLibraryService.shared.fetchImage(byLocalIdentifier: asset.assetID) {
                    appendImage(image: image, id: makeID(id: asset.assetID))
                    print("image appended", asset.id)
                }
            }
            WidgetCenter.shared.reloadAllTimelines()
            print("reloading all timelines")
        }
    }

    func appendImage(image: UIImage, id: String) {
        
        // Save image in userdefaults
        if let userDefaults = UserDefaults(suiteName: appGroupName) {

            let resized = resizeImage(image: image, targetSize: CGSize(width: 702, height: 1519))

            if let jpegRepresentation = resized.jpegData(compressionQuality: 0) {

                userDefaults.set(jpegRepresentation, forKey: id)

                // Append the list and save
                saveIntoUserDefaults()

                // Notify the widget to reload all items
//                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func makeID(id: String) -> String {
        var id = id
        id += "@"
        id += formattedDateOneYearAgo
        
        return id
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let one = Calendar.current.dateComponents([.day], from: date1)
        let two = Calendar.current.dateComponents([.day], from: date2)
        return one.day == two.day
    }
    
    private func saveIntoUserDefaults() {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            
            let data = try! JSONEncoder().encode(allPhotos.map { $0.id })
            userDefaults.set(data, forKey: userDefaultsPhotosKey)
        }
        
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        var widthRatio: CGFloat = targetSize.width / size.width
        var heightRatio: CGFloat = targetSize.height / size.height
        
        if image.size.width > image.size.height {
            widthRatio = targetSize.height / size.height
            heightRatio = targetSize.width / size.width
        }
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let newImage else { return image }
        return newImage
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
