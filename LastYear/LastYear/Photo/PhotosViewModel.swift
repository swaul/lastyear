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
import VisionKit
import Combine
import WidgetKit

public class PhotosViewModel: ObservableObject {
    
    @Published var allPhotos = [PhotoData]() {
        didSet {
            getBestImage()
        }
    }
    @Published var screenShots = [PhotoData]()
    @Published var countFound = 0
    @Published var requestsFailed = 0
    @Published var dateOneYearAgo: Date? {
        didSet {
            guard let dateOneYearAgo else { return }
            formattedDateOneYearAgo = Formatters.dateFormatter.string(from: dateOneYearAgo)
        }
    }
    @Published var formattedDateOneYearAgo: String = ""
    @Published var bestImage: PhotoData? = nil

    @ObservedObject var authService = AuthService.shared
    
    var cancellabels = Set<AnyCancellable>()
    
    init() {
        Helper.removeAll()

        setupBinding()
        dateOneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        getAllPhotos()
    }
    
    func reset() {
        allPhotos.removeAll()
        screenShots.removeAll()
        bestImage = nil
        countFound = 0
        requestsFailed = 0
    }
    
    func setupBinding() {
        authService.$loggedIn.sink { [weak self] isLoggedIn in
            if !isLoggedIn {
                self?.reset()
            }
        }.store(in: &cancellabels)
    }
    
    func getAllPhotos() {
        guard let lastYear = dateOneYearAgo, allPhotos.isEmpty else { return }
        
        requestsFailed = 0
        countFound = 0
        
        let oneBeforeLastYear = Calendar.current.date(byAdding: .day, value: -1, to: lastYear)!.endOfDay
        let oneAfterLastYear = Calendar.current.date(byAdding: .day, value: 1, to: lastYear)!.startOfDay
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", oneBeforeLastYear as NSDate, oneAfterLastYear as NSDate)
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        countFound = results.countOfAssets(with: .image)
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                //                let size = CGSize(width: 700, height: 700) //You can change size here
                manager.requestImage(for: asset, targetSize: .zero, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    if let image = image, !asset.isHidden {
                        let photo = PhotoData(id: self.makeID(id: asset.localIdentifier), image: image, date: asset.creationDate, formattedDate: self.formattedDateOneYearAgo, location: asset.location, isFavorite: asset.isFavorite, sourceType: asset.sourceType)
                        
                        if let date = asset.creationDate, self.isSameDay(date1: date, date2: lastYear) {
                            if asset.mediaSubtypes == .photoScreenshot {
                                self.screenShots.append(photo)
                            } else {
                                self.allPhotos.append(photo)
                                self.appendImage(image: image, id: photo.id)
                            }
                        } else {
                            self.countFound -= 1
                        }
                    } else {
                        self.requestsFailed += 1
                        print("error asset to image ", asset.mediaSubtypes)
                    }
                }
            }
        } else {
            print("No photos to display for ", Formatters.dateFormatter.string(from: lastYear))
        }
    }
    
    func appendImage(image: UIImage, id: String) {
        
        // Save image in userdefaults
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            
            let resized = resizeImage(image: image, targetSize: CGSize(width: 1404, height: 3038))
            
            if let jpegRepresentation = resized.jpegData(compressionQuality: 0) {
                
                userDefaults.set(jpegRepresentation, forKey: id)
                
                // Append the list and save
                saveIntoUserDefaults()
                
                // Notify the widget to reload all items
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func makeID(id: String) -> String {
        var id = id
        id += "@"
        id += formattedDateOneYearAgo
        
        return id
    }
    
    private func saveIntoUserDefaults() {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            
            let data = try! JSONEncoder().encode(allPhotos.map { $0.id })
            userDefaults.set(data, forKey: userDefaultsPhotosKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getBestImage() {
        if !allPhotos.isEmpty, countFound == (allPhotos.count + screenShots.count + requestsFailed) {
            let sorted = allPhotos.sorted()
            bestImage = sorted.first!
        } else if allPhotos.count == 1 && countFound == 1 {
            bestImage = allPhotos.first!
        }
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let one = Calendar.current.dateComponents([.day], from: date1)
        let two = Calendar.current.dateComponents([.day], from: date2)
        return one.day == two.day
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
        
        return newImage!
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
