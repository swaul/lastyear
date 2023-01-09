//
//  ShareLastYearView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.12.22.
//

import SwiftUI
import AWSS3
import AWSCore
import Mantis

struct ShareLastYearView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var originalImage: UIImage?
    
    @State var selectedImage: UIImage?
    @State var currentUpload = 0.0
    @State var uploadDone = false
    @Binding var selected: String?
    @State var description: String = ""
    @State var goto: Bool = false
    @State var showCropper: Bool = false
    @State private var cropShapeType: Mantis.CropShapeType = .rect
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 0.8)
    
    @FocusState var descriptionFocus
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(0.8, contentMode: .fill)
                                .clipped()
                                .padding(.horizontal)
                                .onTapGesture(perform: {
                                    showCropper = true
                                })
                                .fullScreenCover(isPresented: $showCropper, content: {
                                    ImageCropper(gotoImageEdit: $goto, image: $originalImage, croppedImage: $selectedImage, cropShapeType: $cropShapeType, presetFixedRatioType: $presetFixedRatioType)
                                        .ignoresSafeArea()
                                })
                        }
                        if currentUpload == 0 {
                            TextField("Beschreibung", text: $description)
                                .onSubmit {
                                    descriptionFocus = false
                                }
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .focused($descriptionFocus)
                                .padding()
                                .onChange(of: descriptionFocus) { newValue in
                                    if newValue {
                                        proxy.scrollTo(1, anchor: .bottom)
                                    }
                                }
                                .id(1)
                            VStack {
                                Button {
                                    shareLastYear()
                                } label: {
                                    HStack {
                                        Image(systemName: "person.2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30)
                                            .padding(.trailing, 20)
                                        VStack(alignment: .leading) {
                                            Text("Friends")
                                                .font(Font.custom("Poppins-Bold", size: 24))
                                                .foregroundColor(Color.white)
                                            Text("Share with all your friends")
                                                .font(Font.custom("Poppins-Regular", size: 18))
                                                .foregroundColor(Color.white)
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .padding()
                                    .background(Color("gray"))
                                    .cornerRadius(8)
                                }
                                
                                Button {
                                    shareLastYear(toPublic: true)
                                } label: {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 30)
                                            .padding(.trailing, 20)
                                        VStack(alignment: .leading) {
                                            Text("Discovery")
                                                .font(Font.custom("Poppins-Bold", size: 24))
                                                .foregroundColor(Color.white)
                                            Text("Share with all LastYear users")
                                                .font(Font.custom("Poppins-Regular", size: 18))
                                                .foregroundColor(Color.white)
                                        }
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .padding()
                                    .background(Color("gray"))
                                    .cornerRadius(8)
                                }
                                .tag(2)
                            }
                            .padding(.horizontal)
                            
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
                .navigationTitle(Text("Share!"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func findCompression(image: UIImage) -> Double {
        let numbers = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]
        
        for number in numbers {
            if let data = image.jpegData(compressionQuality: number), data.count <= 1000000 {
                return number
            } else {
                continue
            }
        }
        
        return 0.1
    }
    
    func shareLastYear(toPublic: Bool = false) {
        Task {
            guard let user = AuthService.shared.loggedInUser, let selected else { return }
            
            guard
                let image = selectedImage,
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
                        let upload = DiscoveryUpload(
                            id: user.id,
                            likes: [],
                            timePosted: Formatters.dateTimeFormatter.string(from: Date.now),
                            user: user.userName,
                            reactions: [],
                            description: description)
                        if toPublic {
                            shareToPublicStory(upload: upload)
                        } else {
                            shareToFriendsStory(upload: upload)
                        }
                    }
                }
            }
        }
    }
    
    func shareToPublicStory(upload: DiscoveryUpload) {
        FirebaseHandler.shared.shareMemory(to: ._public, discovery: upload) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(()):
                withAnimation {
                    self.uploadDone = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                    }
                    self.shareToFriendsStory(upload: upload)
                }
            }
        }
    }
    
    func shareToFriendsStory(upload: DiscoveryUpload) {
        FirebaseHandler.shared.shareMemory(to: .friends, discovery: upload) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(()):
                Helper.savePostOfToday()
                withAnimation {
                    self.uploadDone = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        
    }
}

struct ShareLastYearView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Test")
        //        ShareLastYearView()
    }
}
