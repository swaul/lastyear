//
//  UserView.swift
//  LastYear
//
//  Created by Paul Kühnel on 14.11.22.
//

import SwiftUI
import AWSS3
import AWSCore
import PhotoSelectAndCrop

struct UserView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State var uiImage: UIImage?
    @State private var showSheet = false
    @State var user: LYUser
            
    @State var cropped: UIImage? = nil
    
    var body: some View {
        VStack {
            Text("Hello \(user.userName)")
                .font(Font.custom("Poppins-Bold", size: 26))
                .foregroundColor(.white)
                .padding()
            if let uiImage {
                ImagePane(image: ImageAttributes(image: Image(uiImage: uiImage), originalImage: uiImage, croppedImage: cropped, scale: 1, xWidth: 10, yHeight: 10), isEditMode: .constant(true))
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
            if let uiImage = cropped {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()

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
    
    func savePP() {
        Task {
            guard let user = AuthService.shared.loggedInUser else { return }
            
            guard
                let data = uiImage?.jpegData(compressionQuality: 0.2)
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

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: LYUser(data: [:])!)
    }
}
