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
import Vision

public class PhotosViewModel: ObservableObject {
    
    @Published var formattedDateOneYearAgo: String = ""
    @Published var bestImage: PhotoData?
    @Published var countFound = 0
    @Published var test = 0 {
        didSet {
            print(allPhotos.count)
        }
    }
    @Published var countDone = 0
    @Published var requestsFailed = 0
    @Published var loadingState: LoadingState = .idle
    @Published var dateOneYearAgo: Date? {
        didSet {
            guard let dateOneYearAgo else { return }
            formattedDateOneYearAgo = Formatters.dateFormatter.string(from: dateOneYearAgo)
        }
    }
    @Published var allPhotos = [PhotoData]() {
        didSet {
            withAnimation {
                countDone = allPhotos.count
            }
            getBestImage()
//            checkIfDone()
        }
    }
    var group = DispatchGroup()
    var many: Bool = false
    
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
        bestImage = nil
        countFound = 0
        countDone = 0
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
        withAnimation {
            loadingState = .loading
        }
        
        guard let lastYear = dateOneYearAgo else {
            loadingState = .failed
            return
        }
        
        requestsFailed = 0
        countFound = 0
        countDone = 0
        test = 0
        
        let oneBeforeLastYear = Calendar.current.date(byAdding: .day, value: -1, to: lastYear)!.endOfDay
        let oneAfterLastYear = Calendar.current.date(byAdding: .day, value: 1, to: lastYear)!.startOfDay
        
        let manager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", oneBeforeLastYear as NSDate, oneAfterLastYear as NSDate)
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        countFound = results.countOfAssets(with: .image)
        
        guard countFound != allPhotos.count else { return }
        allPhotos.removeAll()
        
        many = countFound > 20
        
        if results.count > 0 {
            for i in 0..<results.count {
                group.enter()
                let asset = results.object(at: i)
                manager.requestImage(for: asset, targetSize: .zero, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    if let image = image, !asset.isHidden {
                        let photo = PhotoData(id: self.makeID(id: asset.localIdentifier), image: image, date: asset.creationDate, formattedDate: self.formattedDateOneYearAgo, location: asset.location, isFavorite: asset.isFavorite, sourceType: asset.sourceType)
                        
                        if let date = asset.creationDate, self.isSameDay(date1: date, date2: lastYear) {
                            if asset.mediaSubtypes == .photoScreenshot {
                                photo.photoType = .screenshot
                                self.allPhotos.append(photo)
                                self.test += 1
                                self.group.leave()
                            } else {
                                if asset.mediaSubtypes == .photoLive {
                                    photo.photoType = .live
                                }
                                self.allPhotos.append(photo)
                                self.appendImage(image: image, id: photo.id)
                                self.test += 1
                                self.group.leave()
                            }
                        } else {
                            self.test += 1
                            self.group.leave()
                            self.countFound -= 1
                        }
                    } else {
                        self.group.leave()
                        self.requestsFailed += 1
                        print("error asset to image ", asset.mediaSubtypes)
                    }
                }
            }
            group.notify(queue: .main) {
                withAnimation {
                    self.loadingState = .done
                    WidgetCenter.shared.reloadAllTimelines()
                    print(Helper.getImageIdsFromUserDefault().count)
                }
            }
        } else {
            loadingState = .noPictures
            print("No photos to display for ", Formatters.dateFormatter.string(from: lastYear))
        }
    }

    func appendImage(image: UIImage, id: String) {
        
        // Save image in userdefaults
        if let userDefaults = UserDefaults(suiteName: "photos") {
            
            let resized = resizeImage(image: image, targetSize: CGSize(width: 1004, height: 2172))
            
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
    
    private func saveIntoUserDefaults() {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            
            let data = try! JSONEncoder().encode(allPhotos.map { $0.id })
            userDefaults.set(data, forKey: userDefaultsPhotosKey)
        }
        
//        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getBestImage() {
        if !allPhotos.isEmpty, countFound == (allPhotos.count + requestsFailed) {
            let sorted = allPhotos.sorted()
            bestImage = sorted.first!
        } else if allPhotos.count == 1 && countFound == 1 {
            bestImage = allPhotos.first!
        } else if !allPhotos.isEmpty {
            bestImage = allPhotos.first!
        }
    }
//
//    func checkIfDone() {
//        if countDone >= 1 && many {
//            withAnimation {
//                loadingState = .done
//            }
//        }
//        if countDone == countFound {
//            withAnimation {
//                loadingState = .done
//            }
//            withAnimation {
//                many = false
//            }
//        }
//    }
    
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

public enum LoadingState {
    case loading
    case loadingMany
    case idle
    case failed
    case noPictures
    case done
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
