//
//  FriendLastYear.swift
//  LastYear
//
//  Created by Paul Kühnel on 28.10.22.
//

import SwiftUI
import FirebaseStorage
import ImageViewer
import AWSS3
import AWSCore

struct FriendLastYear: View {
    
    @State var user: String = ""
    @State var image: Image? = nil
    @State var id: String = ""
    @State var currentDownload = 0.0
    @State var downloadDone = false
    @State var timePosted: Double = 0.0

    var body: some View {
        VStack {
            VStack {
                HStack {
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
}

struct FriendLastYear_Previews: PreviewProvider {
    static var previews: some View {
        FriendLastYear()
    }
}
