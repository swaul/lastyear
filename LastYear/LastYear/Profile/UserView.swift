//
//  UserView.swift
//  LastYear
//
//  Created by Paul Kühnel on 14.11.22.
//

import SwiftUI
import AWSS3
import AWSCore

struct UserView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var noImage: Bool
    
    @Binding var uiImage: UIImage?
    @State private var showSheet = false
    @State var user: LYUser
                
    var body: some View {
        VStack {
            Text("Hello \(user.userName)")
                .font(Font.custom("Poppins-Bold", size: 26))
                .foregroundColor(.white)
                .padding()
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .onTapGesture {
                        showSheet = true
                    }
            } else if noImage {
                Image(uiImage: UIImage(named: "fallback")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .onTapGesture {
                        showSheet = true
                    }
            } else {
                ZStack {
                    Circle()
                        .foregroundColor(.gray)
                        .aspectRatio(1, contentMode: .fit)
                    ProgressView()
                }
                .padding()
                .onTapGesture {
                    showSheet = true
                }
            }
            Spacer()
                .fullScreenCover(isPresented: $showSheet) {
                    ImagePicker(selectedImage: $uiImage)
                }
            Button {
                savePP()
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(Font.custom("Poppins-Bold", size: 16))
                        .foregroundColor(Color("backgroundColor"))
                        .padding()
                    Spacer()
                    
                }
            }
            .background(Color("primary"))
            .cornerRadius(8)
            .padding(.vertical)
            HStack {
                Spacer()
                Button {
                    print("Delete acc")
                } label: {
                    Text("delete account")
                        .font(Font.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.red)
                        .padding()
                }
                Spacer()
            }
            .background(Color.red.opacity(0.2))
            .cornerRadius(8)
        }
        .padding()
    }
    
    func cropImage2(image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let height = image.size.height
        let width = image.size.width
        if width < height {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), true, 0.0)
            image.draw(at: CGPoint(x: 0, y: (width - height) / 2))
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: height, height: height), true, 0.0)
            image.draw(at: CGPoint(x: (height - width) / 2, y: 0))
        }

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func savePP() {
        Task {
            guard let user = AuthService.shared.loggedInUser else { return }
            
            guard let image = cropImage2(image: uiImage) else { return }
            
            guard
                let data = image.jpegData(compressionQuality: 0.2)
            else { return }
                        
            var imageId = user.id
            imageId += "profilePicture"
            
            let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
                
                print("percentage done:", progress.fractionCompleted)
            }
            let request = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = progressBlock
            
            request.uploadData(data, bucket: "lastyearapp", key: imageId, contentType: "image/jpeg", expression: expression) { task, error in
                if let error {
                    print(error.localizedDescription)
                } else {
                    print(task.progress)
                    saveImage(id: imageId)
                }
            }
        }
    }
    
    func saveImage(id: String) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let jpegRepresentation = uiImage?.jpegData(compressionQuality: 0.75) {
                userDefaults.set(jpegRepresentation, forKey: id)
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
