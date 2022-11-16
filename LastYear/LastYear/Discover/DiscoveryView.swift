//
//  DiscoveriesView.swift
//  LastYear
//
//  Created by Paul Kühnel on 08.11.22.
//

import SwiftUI
import FirebaseStorage
import ImageViewer
import AWSS3
import AWSCore

struct DiscoveryView: View {
    
    @State var user: String = ""
    @State var userPP: Image? = nil
    @State var image: Image? = nil
    @State var id: String = ""
    @State var currentDownload = 0.0
    @State var downloadDone = false
    @State var timePosted: Double
    @State var liked = false
    @State var likes: [String]
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack {
                        ZStack {
                            if let userPP = userPP {
                                userPP
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 33, height: 33)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .foregroundColor(.gray)
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 33, height: 33)                            
                                ProgressView()
                            }
                        }
                        Text(user)
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(Color.white)
                        Spacer()
                        Text(getTimePosted())
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(Color.white)
                    }
                    .padding(.horizontal)
                    ZStack {
                        if let image = image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .foregroundColor(.gray)
                                .aspectRatio(1, contentMode: .fit)
                            ProgressView()
                        }
                    }
                }
            }
            .padding(.bottom, 12)
            .onAppear {
                getImage()
                getPP()
                if likes.contains(where: { $0 == AuthService.shared.loggedInUser?.id ?? "" }) {
                    liked = true
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button {
                            liked.toggle()
                            like()
                        } label: {
                            Image(systemName: liked ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 38, height: 38)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        Text(String(liked ? likes.count + 1 : likes.count))
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(Color.white)
                    }
                }
            }
            .padding()
        }
    }
    
    func like() {
        guard let id = AuthService.shared.loggedInUser?.id else { return }

        FirebaseHandler.shared.changeLike(selfId: id, user: self.id, remove: !liked) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(()):
                simpleSuccess()
            }
        }
    }
    
    func getTimePosted() -> String {
        if (timePosted / 60) < 60 {
            let time = Int((timePosted / 60).rounded())
            return "\(time)m ago"
        } else {
            return "\(Int((timePosted / 60 / 60).rounded()))h ago"
        }
    }
    
    func getImage() {
        guard image == nil else { return }
        //        let reference = Storage.storage().reference()
        //
        //        let task = reference.child("images/\(id)").getData(maxSize: 10 * 1024 * 1024) { data, error in
        //            if let error = error {
        //                print(error.localizedDescription)
        //            } else {
        //                guard let image = UIImage(data: data!) else { return }
        //                self.image = Image(uiImage: image)
        //                self.downloadDone = true
        //            }
        //        }
        //
        //        task.observe(.progress) { snapshot in
        //            let currentValue = (100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount))
        //            print(currentValue)
        //            self.currentDownload = currentValue
        //        }
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else { return }
            self.image = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
            withAnimation {
                self.downloadDone = true
            }
        }
    }
    
    func getPP() {
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        var id = id
        id += "profilePicture"
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else { return }
            self.userPP = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(timePosted: 0.0, likes: ["12"])
    }
}
