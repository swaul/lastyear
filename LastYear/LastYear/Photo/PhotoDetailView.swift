//
//  PhotoDetailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI

struct PhotoDetailView: View {
    
    var image: PhotoData
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var body: some View {
        ZStack {
            VStack {
                image.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                HStack {
                    Button {
                        shareToStory()
                    } label: {
                        Image("instagram")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 48)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Text(formatter.string(from: image.date!))
                        Text(image.city ?? "No locaton")
                    }
                }
                .padding()

            }
        }
    }
    
    func shareToStory() {
        if let storiesUrl = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let imageData = image.uiImage.pngData() else { return }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                    "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3"
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                
            } else if let url = URL(string: "https://instagram.com"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Sorry the application is not installed")
            }
        }
    }
}
