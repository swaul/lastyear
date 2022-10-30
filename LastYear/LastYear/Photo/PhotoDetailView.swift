//
//  PhotoDetailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import UIKit
import FirebaseStorage
import ImageViewer
import BackgroundTasks

struct PhotoDetailView: View {
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var images: [PhotoData]
    
    //    let filterTypes: [FilterType] = [.Chrome, .Fade, .Instant, .Mono, .Noir, .Process, .Tonal, .Transfer, .none]
    //
    //    @State var filterIndex: Int = 0
    //    @State var currentFilter: FilterType = .none
    @State var fullscreenImage: Bool = false
    @State var selected: String
    @State var isShowingiMessages = false
    @State var isShowingShare = false
    @State var shareToLastYearShowing = false
    @State var currentUpload = 0.0
    @State var uploadDone = false
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
        return images.first(where: { $0.id == selected })?.waterMarkedImage
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                LogoView(size: 35)
                    .padding()
                Spacer()
                if #available(iOS 16, *) {
                    GeometryReader { reader in
                        TabView(selection: $selected) {
                            ForEach(images, id: \.id) { image in
                                Image(uiImage: image.waterMarkedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white, lineWidth: 3)
                                    )
                                    .padding()
                                    .tag(image.id)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .onTapGesture { point in
                            let firstThird = reader.size.width / 3
                            let lastThird = reader.size.width - firstThird
                            
                            if point.x < firstThird {
                                toLeft()
                            } else if point.x > firstThird && point.x < lastThird {
                                fullscreenImage = true
                            } else {
                                toRight()
                            }
                        }
                        .offset(x: indexIsLimit ? -8 : 0)
                        .animation(Animation.default.repeatCount(3, autoreverses: true).speed(6), value: indexIsLimit)
                    }
                } else {
                    TabView(selection: $selected) {
                        ForEach(images, id: \.id) { image in
                            Image(uiImage: image.waterMarkedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white, lineWidth: 3)
                                )
                                .padding()
                                .tag(image.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                Spacer()
                HStack {
                    VStack(spacing: 0) {
                        Button {
                            shareToLastYearShowing = true
                        } label: {
                            Image("fallback")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 4)
                        Text("Last Year")
                            .font(Font.custom("Poppins-Bold", size: 12))
                            .foregroundColor(Color.white)
                    }
                    VStack(spacing: 0) {
                        Button {
                            shareToStory()
                        } label: {
                            Image("instagram")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 4)
                        Text("Instagram")
                            .font(Font.custom("Poppins-Bold", size: 12))
                            .foregroundColor(Color.white)
                    }
                    VStack(spacing: 0) {
                        Button {
                            isShowingiMessages = true
                        } label: {
                            Image(systemName: "message")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 4)
                        Text("iMessage")
                            .font(Font.custom("Poppins-Bold", size: 12))
                            .foregroundColor(Color.white)
                    }
                    if #available(iOS 16, *) {
                        VStack {
                            ShareLink(item: Image(uiImage: selectedImage!), preview: SharePreview("Look at my memory from LastYear!", image: Image(uiImage: selectedImage!))) {
                                Image(systemName: "ellipsis.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 4)
                            Text("Others")
                                .font(Font.custom("Poppins-Bold", size: 12))
                                .foregroundColor(Color.white)
                        }
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
                .sheet(isPresented: $isShowingiMessages) {
                    MessageComposeView(recipients: [], body: "Look at my memory from LastYear", attachment: selectedImage) { messageSent in
                        print("MessageComposeView with message sent? \(messageSent)")
                    }
                }
                .sheet(isPresented: $isShowingShare) {
                    ActivityViewController(activityItems: [selectedImage!])
                }
                .sheet(isPresented: $shareToLastYearShowing) {
                    if #available(iOS 16, *) {
                        VStack {
                            HStack {
                                Text("Share to your story")
                                    .font(.largeTitle)
                                    .padding()
                                Spacer()
                            }
                            Spacer()
                            if currentUpload == 0 {
                                Button {
                                    shareLastYear()
                                } label: {
                                    Text("Share!")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(Color("backgroundColor"))
                                        .cornerRadius(10)
                                }
                                .padding()
                            } else if uploadDone {
                                Text("Upload done")
                                    .font(.title)
                                    .foregroundColor(.green)
                            } else {
                                VStack {
                                    Text("\(Int(currentUpload.rounded())) %")
                                    ProgressView(value: currentUpload, total: 100.0)
                                        .padding(.horizontal)
                                    Text("Uploading")
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                        .presentationDetents([.fraction(0.2)])
                    } else {
                        VStack {
                            HStack {
                                Text("Share to your story")
                                    .font(.largeTitle)
                                    .padding()
                                Spacer()
                            }
                            Spacer()
                            if currentUpload == 0 {
                                Button {
                                    shareLastYear()
                                } label: {
                                    Text("Share!")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(Color("backgroundColor"))
                                        .cornerRadius(10)
                                }
                                .padding()
                            } else if uploadDone {
                                Text("Upload done")
                                    .font(.title)
                                    .foregroundColor(.green)
                            } else {
                                VStack {
                                    Text("\(Int(currentUpload.rounded())) %")
                                    ProgressView(value: currentUpload, total: 100.0)
                                        .padding(.horizontal)
                                    Text("Uploading")
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .overlay(ImageViewer(image: .constant(Image(uiImage: selectedImage!)), viewerShown: $fullscreenImage, closeButtonTopRight: true))
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
    
    func searchImage() {
        
        guard let selected = selected.split(separator: "@").first, let url = URL(string: "photos-redirect://image=\(selected)"),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func findCompression(image: UIImage) -> Double {
        let numbers = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]
        
        for number in numbers {
            if let data = image.jpegData(compressionQuality: number), data.count <= 10485760 {
                return number
            } else {
                continue
            }
        }
        
        return 0.1
    }
    
    func shareLastYear() {
        guard let user = AuthService.shared.loggedInUser else { return }
        let storageRef = Storage.storage().reference()
        
        guard let image = selectedImage, let data = image.jpegData(compressionQuality: findCompression(image: image)) else { return }
        
        let date = Formatters.dateTimeFormatter.string(from: Date.now)
        
        // Create a reference to the file you want to upload
        let imagesRef = storageRef.child("images/\(date)")
        
        let uploadTask = imagesRef.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(metadata?.path)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let currentValue = (100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount))
            print(currentValue)
            self.currentUpload = currentValue
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("image uploaded to", snapshot.reference)
            let now = Date.now
            let timeNow = Formatters.dateTimeFormatter.string(from: now)
            FirebaseHandler.shared.saveUploadedImage(user: user.id, imageId: date) { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(()):
                    print("Uploaded:", selected)
                    withAnimation {
                        self.uploadDone = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.shareToLastYearShowing = false
                        }
                    }
                }
            }
            uploadTask.removeAllObservers()
        }
        
        uploadTask.observe(.failure) { snapshot in
            print(snapshot.error)
        }
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
    
    func shareToWhatsapp() {
        guard let image = selectedImage,
              let imageData = image.pngData(),
              let whatsappURL = URL(string: "whatsapp://send")
        else { return }
        
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        }
    }
    
    //    func filteredImage(image: UIImage) -> UIImage {
    //        return image.addFilter(filter: currentFilter)
    //    }
    
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
            
            let text = text.drawImagesAndText(imageSize: rect.size, watermarkHeight: resizedWatermark.size.height)
            let resizedText = text.resizeToWidth(scaledToWidth: resizedWatermark.size.width * 0.75)
            
            UIGraphicsBeginImageContextWithOptions(self.size, true, 0)
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            
            let watermarkY = (rect.height - resizedWatermark.size.height - 40)
            let watermarkX = (rect.width / 2 - resizedWatermark.size.width / 2)
            let dateY = (watermarkY - resizedText.size.height / 2 - 40)
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
    
    func drawImagesAndText(imageSize: CGSize, watermarkHeight: CGFloat) -> UIImage {
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
                .font: UIFont(name: "Poppins-Bold", size: watermarkHeight * 0.8)!,
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
