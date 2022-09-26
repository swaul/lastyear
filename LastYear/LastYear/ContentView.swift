//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import Photos
import AVFoundation
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var authService: AuthService
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var mockPhotos = [
        PhotoData(id: UUID().uuidString, image: Image("Image1")),
        PhotoData(id: UUID().uuidString, image: Image("Image2")),
        PhotoData(id: UUID().uuidString, image: Image("Image3")),
        PhotoData(id: UUID().uuidString, image: Image("Image4")),
        PhotoData(id: UUID().uuidString, image: Image("Image5")),
        PhotoData(id: UUID().uuidString, image: Image("Image6")),
        PhotoData(id: UUID().uuidString, image: Image("Image7"))
    ]
    
    @State var allPhotos = [PhotoData]()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: layout) {
                        ForEach(allPhotos) { photo in
                            NavigationLink {
                                PhotoDetailView(image: photo)
                            } label: {
                                PhotoCard(image: photo)
                            }
                        }
                    }
                    .onAppear {
                        getAllPhotos()
                    }
                    .padding(12)
                }
            }
        }
    }
    
    fileprivate func getAllPhotos() {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        guard let lastYear = lastYear else { return }
        
        let nsDate = NSDate(timeIntervalSinceNow: lastYear.timeIntervalSinceNow)
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //        fetchOptions.predicate = NSPredicate(format: "creationDate == %@", lastYear as NSDate)
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if results.count > 0 {
            for i in 0..<results.count {
                let asset = results.object(at: i)
                let size = CGSize(width: 700, height: 700) //You can change size here
                manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                    if let image = image {
                        let photo = PhotoData(id: asset.localIdentifier, image: Image(uiImage: image), date: asset.creationDate, location: asset.location)
                        if let date = asset.creationDate, isSameDay(date1: date, date2: lastYear) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
