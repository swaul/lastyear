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
import AWSS3
import AWSCore
import Photos

struct PhotoDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var images: [PhotoData]
    @State var selectedImage: UIImage? = nil
    @State var fullscreenImage: Bool = false
    @State var selected: Int = 0
    @State var isShowingiMessages = false
    @State var isShowingShare = false
    @State var shareToLastYearShowing = false
    @State var currentUpload = 0.0
    @State var uploadDone = false
    @State var toolbarShowing: Bool = true
    @State var zoomScale: CGFloat
    @State var previousZoomScale: CGFloat = 1
    private let minZoomScale: CGFloat = 1
    private let maxZoomScale: CGFloat = 5
    
    var selectedImageId: String? {
        return images[selected].assetID
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                ZStack {
                    if let uiImage = selectedImage, let image = Image(uiImage: uiImage)  {
                        GeometryReader { reader in
                            ScrollView(
                                [.vertical, .horizontal],
                                showsIndicators: false
                            ) {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                                    .onTapGesture(count: 2, perform: onImageDoubleTapped)
                                    .onTapGesture(count: 1, perform: {
                                        withAnimation {
                                            toolbarShowing.toggle()
                                        }
                                    })
                                    .gesture(zoomGesture)
                                    .frame(width: reader.size.width * max(minZoomScale, zoomScale))
                                    .frame(maxHeight: .infinity)
                            }
                        }
                    } else {
                        Rectangle()
                            .foregroundColor(.gray)
                            .aspectRatio(1, contentMode: .fit)
                        ProgressView()
                    }
                }
                .ignoresSafeArea()
                .task {
                    await loadImageAsset()
                }
                // Finally, when the view disappears, we need to free it
                // up from the memory
                .onDisappear {
                    selectedImage = nil
                }
                .ignoresSafeArea()
                Spacer()
            }
            .ignoresSafeArea()
            if toolbarShowing {
                VStack {
                    toolbarTop
                        .background(.thinMaterial)
                        .animation(.easeInOut, value: toolbarShowing)
                        .transition(.move(edge: .top))
                    Spacer()
                    toolbarBot
                        .background(.thinMaterial)
                        .animation(.easeInOut, value: toolbarShowing)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .sheet(isPresented: $isShowingiMessages) {
            MessageComposeView(recipients: [], body: "Look at my memory from LastYear", attachment: selectedImage) { messageSent in
                print("MessageComposeView with message sent? \(messageSent)")
            }
        }
        .sheet(isPresented: $isShowingShare) {
            ActivityViewController(activityItems: [selectedImage!])
        }
        .sheet(isPresented: $shareToLastYearShowing) {
            if #available(iOS 16.0, *) {
                VStack {
                    if currentUpload == 0 {
                        Button {
                            shareLastYear()
                        } label: {
                            HStack {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 25)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Friends")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(Color.white)
                                    Text("Share with all your friends")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(Color("gray"))
                            .cornerRadius(8)
                        }
                        .padding()
                        Button {
                            shareLastYear(toPublic: true)
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 25)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Discovery")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(Color.white)
                                    Text("Share with all LastYear users")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(Color("gray"))
                            .cornerRadius(8)
                        }
                        .padding()
                        Text("Share!")
                            .font(Font.custom("Poppins-Bold", size: 28))
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
                }
                .presentationDetents([.fraction(0.4)])
            } else {
                VStack {
                    if currentUpload == 0 {
                        Button {
                            shareLastYear()
                        } label: {
                            HStack {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 25)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Friends")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(Color.white)
                                    Text("Share with all your friends")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(Color("gray"))
                            .cornerRadius(8)
                        }
                        .padding()
                        Button {
                            shareLastYear(toPublic: true)
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 25)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Discovery")
                                        .font(Font.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(Color.white)
                                    Text("Share with all LastYear users")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(Color("gray"))
                            .cornerRadius(8)
                        }
                        .padding()
                        Text("Share!")
                            .font(Font.custom("Poppins-Bold", size: 28))
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
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func loadImageAsset(
        targetSize: CGSize = PHImageManagerMaximumSize
    ) async {
        guard let uiImage = try? await PhotoLibraryService.shared
            .fetchImage(
                byLocalIdentifier: selectedImageId!,
                targetSize: targetSize
            ) else {
            selectedImage = nil
            return
        }
        selectedImage = uiImage
    }
    
    func resetImageState() {
        withAnimation(.interactiveSpring()) {
            zoomScale = 1
        }
    }
    
    /// On double tap
    func onImageDoubleTapped() {
        /// Zoom the photo to 5x scale if the photo isn't zoomed in
        if zoomScale == 1 {
            withAnimation(.spring()) {
                zoomScale = 5
            }
        } else {
            /// Otherwise, reset the photo zoom to 1x
            resetImageState()
        }
    }
    
    var toolbarTop: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Back")
            }
            Spacer()
            LogoView(size: 30)
            Spacer()
        }
        .padding()
    }
    
    var toolbarBot: some View {
            HStack {
                VStack(spacing: 4) {
                    Button {
                        shareToStory()
                    } label: {
                        Image("instagram")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    Text("Instagram")
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.white)
                }
                VStack(spacing: 4) {
                    Button {
                        isShowingiMessages = true
                    } label: {
                        Image(systemName: "message")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    Text("iMessage")
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.white)
                }
                if let image = selectedImage, #available(iOS 16, *) {
                    VStack(spacing: 4) {
                        ShareLink(item: Image(uiImage: selectedImage!), preview: SharePreview("Look at my memory from LastYear!", image: Image(uiImage: selectedImage!))) {
                            Image(systemName: "ellipsis.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        Text("Others")
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundColor(Color.white)
                    }
                } else {
                    ProgressView()
                        .frame(width: 32)
                }
                Spacer()
                Button {
                    shareToLastYearShowing = true
                } label: {
                    VStack(spacing: 4) {
                        Text("Share to")
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundColor(Color.white)
                        Image("logoSmall")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                    }
                }
            }
        .padding()
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
    
    func shareLastYear(toPublic: Bool = false) {
        Task {
            guard let user = AuthService.shared.loggedInUser else { return }
            
            guard
                let imageId = selectedImageId,
                let image = try await PhotoLibraryService.shared.fetchImage(byLocalIdentifier: imageId),
                let data = image.jpegData(compressionQuality: findCompression(image: image))
            else { return }
                        
            let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
                print("percentage done:", progress.fractionCompleted)
                withAnimation {
                    currentUpload = progress.fractionCompleted * 100
                }
            }
            let request = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = progressBlock
            
            request.uploadData(data, bucket: "lastyearapp", key: user.id, contentType: "image/jpeg", expression: expression) { task, error in
                if let error {
                    print(error.localizedDescription)
                } else {
                    if task.status == .completed {
                        if toPublic {
                            FirebaseHandler.shared.shareToPublic(discovery: DiscoveryUpload(id: user.id, likes: [], timePosted: Formatters.dateTimeFormatter.string(from: Date.now), user: user.userName)) { result in
                                switch result {
                                case .failure(let error):
                                    print(error.localizedDescription)
                                case .success(()):
                                    withAnimation {
                                        FirebaseHandler.shared.saveUploadedImage(user: user.id, imageId: Formatters.dateTimeFormatter.string(from: Date.now)) { result in
                                            switch result {
                                            case .failure(let error):
                                                print(error.localizedDescription)
                                            case .success(()):
                                                withAnimation {
                                                    self.uploadDone = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        self.shareToLastYearShowing = false
                                                    }
                                                }
                                            }
                                        }
                                        self.uploadDone = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.shareToLastYearShowing = false
                                        }
                                    }
                                }
                            }
                        } else {
                            FirebaseHandler.shared.saveUploadedImage(user: user.id, imageId: Formatters.dateTimeFormatter.string(from: Date.now)) { result in
                                switch result {
                                case .failure(let error):
                                    print(error.localizedDescription)
                                case .success(()):
                                    withAnimation {
                                        self.uploadDone = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.shareToLastYearShowing = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shareToStory() {
        Task {
            if let storiesUrl = URL(string: "instagram-stories://share"), let imageId = selectedImageId, let image = try await PhotoLibraryService.shared.fetchImage(byLocalIdentifier: imageId) {
                if await UIApplication.shared.canOpenURL(storiesUrl) {
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
                    
                    await UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                    
                } else if let url = URL(string: "https://instagram.com"), await UIApplication.shared.canOpenURL(url) {
                    await UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Sorry the application is not installed")
                }
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

extension PhotoDetailView {
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged(onZoomGestureStarted)
            .onEnded(onZoomGestureEnded)
    }
    
    func onZoomGestureStarted(value: MagnificationGesture.Value) {
        withAnimation(.easeIn(duration: 0.1)) {
            let delta = value / previousZoomScale
            previousZoomScale = value
            let zoomDelta = zoomScale * delta
            var minMaxScale = max(minZoomScale, zoomDelta)
            minMaxScale = min(maxZoomScale, minMaxScale)
            zoomScale = minMaxScale
        }
    }
    
    func onZoomGestureEnded(value: MagnificationGesture.Value) {
        previousZoomScale = 1
        if zoomScale <= 1 {
            withAnimation(.interactiveSpring()) {
                zoomScale = 1
            }
        } else if zoomScale > 5 {
            zoomScale = 5
        }
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
