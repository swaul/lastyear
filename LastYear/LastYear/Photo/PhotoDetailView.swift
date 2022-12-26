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
    
    @State var selectedImage: UIImage? = nil
    @State var fullscreenImage: Bool = true
    @Binding var selected: String?
    @State var isShowingiMessages = false
    @State var isShowingShare = false
    @State var shareToLastYearShowing = false
    @State var toolbarShowing: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                VStack {
                    ZStack {
                        if let selectedImage, let image = Image(uiImage: selectedImage) {
                            ImageViewer(image: .constant(image), viewerShown: $fullscreenImage, closeButtonTopRight: false)
                                .ignoresSafeArea()
                                .onChange(of: fullscreenImage) { newValue in
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .onTapGesture {
                                    withAnimation {
                                        toolbarShowing.toggle()
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
                    .onChange(of: selected) { _ in
                        Task {
                            await loadImageAsset()
                        }
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
            .navigationBarHidden(true)
        }
    }
    
    func loadImageAsset(
        targetSize: CGSize = PHImageManagerMaximumSize
    ) async {
        
        guard let selected else { return }
        
        guard let uiImage = try? await PhotoLibraryService.shared
            .fetchImage(
                byLocalIdentifier: selected,
                targetSize: targetSize
            ) else {
            selectedImage = nil
            return
        }
        selectedImage = uiImage
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
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("Look at my memory from LastYear!", image: Image(uiImage: image))) {
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
            NavigationLink {
                ShareLastYearView(selectedImage: selectedImage, selected: $selected)
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
    
    func shareToStory() {
        Task {
            if let storiesUrl = URL(string: "instagram-stories://share"), let image = selectedImage {
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

extension View {
    func navigate<Content: View>(_ condition: Binding<Bool>, content: Content) -> some View {
        if condition.wrappedValue {
            return AnyView(overlay(
                NavigationLink(
                    destination: content,
                    isActive: condition
                ) {}
            ))
        }
        return AnyView(self)
    }
}
