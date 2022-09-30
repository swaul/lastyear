//
//  PhotoDetailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import UIKit

struct PhotoDetailView: View {
            
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var images: [PhotoData]
    
    @State var selected: String
    @State var indexIsLimit: Bool = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    indexIsLimit = false
                }
            }
        }
    }
    
    var selectedImage: UIImage? {
        return images.first(where: { $0.id == selected })?.uiImage
    }
    
    var body: some View {
        ZStack {
            VStack {
                LogoView()
                .padding()
                Spacer()
                GeometryReader { reader in
                    TabView(selection: $selected) {
                        ForEach(images, id: \.id) { image in
                            Image(uiImage: image.uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .border(.white, width: 4)
                                .padding()
                                .cornerRadius(20)
                                .tag(images)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onTapGesture { point in
                        let half = reader.size.width / 2
                        if point.x < half {
                            toLeft()
                        } else {
                            toRight()
                        }
                    }
                    .offset(x: indexIsLimit ? -8 : 0)
                    .animation(Animation.default.repeatCount(3, autoreverses: true).speed(6), value: indexIsLimit)
                }
                Spacer()
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
                    
                    if let image = images.first(where: { $0.id == selected }) {
                        VStack {
                            Text(formatter.string(from: image.date!))
                            Text(image.city ?? "No locaton")
                        }
                    }
                }
                .padding()

            }
        }
    }
    
    func toLeft() {
        let index = images.firstIndex(of: images.first(where: { $0.id == selected })!)
        guard let index, index > 0 else {
            simpleError()
            withAnimation {
                indexIsLimit = true
            }
            return
        }
        selected = images[images.index(before: index)].id
    }
    
    func toRight() {
        let index = images.firstIndex(of: images.first(where: { $0.id == selected })!)
        guard let index, index < (images.count - 1) else {
            simpleError()
            withAnimation {
                indexIsLimit = true
            }
            return
        }
        selected = images[images.index(after: index)].id
    }
    
    func shareToStory() {
        if let storiesUrl = URL(string: "instagram-stories://share"), let image = selectedImage {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let imageData = image.pngData() else { return }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.backgroundImage": imageData,
//                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor": "#F8B729",
                    "com.instagram.sharedSticker.backgroundBottomColor": "#242424"
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                
                simpleSuccess()
                
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                
            } else if let url = URL(string: "https://instagram.com"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Sorry the application is not installed")
            }
        }
    }
    
    func simpleError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

extension UIImage {
    func addWatermark(text: String) -> UIImage {
        if let watermark = UIImage(named: "aboutlastyear")  {
            
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            let resizedWatermark = watermark.resizeToWidth(scaledToWidth: rect.width * 0.5)
            print("full image width: \(rect.width). watermark width: \(resizedWatermark.size.width)")
            
            let text = text.drawImagesAndText(imageSize: rect.size)
            let resizedText = text.resizeToWidth(scaledToWidth: resizedWatermark.size.width * 0.75)

            UIGraphicsBeginImageContextWithOptions(self.size, true, 0)
            let context = UIGraphicsGetCurrentContext()!
            
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            
            let watermarkY = (rect.height - resizedWatermark.size.height - 80)
            let watermarkX = (rect.width / 2 - resizedWatermark.size.width / 2)
            let dateY = (watermarkY - resizedText.size.height / 2)
            let dateX = (rect.width / 2 - resizedText.size.width / 2)
            
            self.draw(in: rect, blendMode: .normal, alpha: 1)
            resizedWatermark.draw(in: CGRectMake(watermarkX, watermarkY, resizedWatermark.size.width, resizedWatermark.size.height), blendMode: .normal, alpha: 1)
            resizedText.draw(in: CGRectMake(dateX, dateY, resizedText.size.width, resizedText.size.height), blendMode: .normal, alpha: 1)
            
            guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return self }
            UIGraphicsEndImageContext()
            return result
        } else {
            return self
        }
    }
    
    func resizeToWidth(scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = self.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension String {
    
    func drawImagesAndText(imageSize: CGSize) -> UIImage {
        // 1
        let size = CGSize(width: imageSize.width * 0.25, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)

        let img = renderer.image { ctx in
            // 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowBlurRadius = 5
            
            // 3
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Poppins-Bold", size: 80)!,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white,
                .shadow: shadow
            ]

            // 4
            let attributedString = NSAttributedString(string: self, attributes: attrs)

            // 5
            attributedString.draw(with: CGRect(x: 0, y: 0, width: imageSize.width * 0.25, height: 200), options: .usesLineFragmentOrigin, context: nil)

        }

        return img
        // 6
    }
    
}
