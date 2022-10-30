//
//  FriendLastYear.swift
//  LastYear
//
//  Created by Paul Kühnel on 28.10.22.
//

import SwiftUI
import FirebaseStorage
import ImageViewer

struct FriendLastYear: View {
    
    @State var user: String = ""
    @State var image: Image = Image("fallback")
    @State var id: String = ""
    @State var currentDownload = 0.0
    @State var downloadDone = false

    var body: some View {
        VStack {
            VStack {
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("primary"), lineWidth: 3)
                        )
                        .padding()
                    if !downloadDone {
                        VStack {
                            Spacer()
                            ProgressView(value: currentDownload, total: 100.0)
                        }
                    }
                }
            }
            Text(user)
                .font(Font.custom("Poppins-Bold", size: 20))
                .foregroundColor(Color.white)
        }
        .onAppear {
            getImage()
        }
    }
    
    func getImage() {
        let reference = Storage.storage().reference()
        
        let task = reference.child("images/\(id)").getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let image = UIImage(data: data!) else { return }
                self.image = Image(uiImage: image)
                self.downloadDone = true
            }
        }
        
        task.observe(.progress) { snapshot in
            let currentValue = (100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount))
            print(currentValue)
            self.currentDownload = currentValue
        }
    }
}

struct FriendLastYear_Previews: PreviewProvider {
    static var previews: some View {
        FriendLastYear()
    }
}
