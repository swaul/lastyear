//
//  DiscoveriesView.swift
//  LastYear
//
//  Created by Paul Kühnel on 08.11.22.
//

import SwiftUI
import FirebaseStorage
import ImageViewer

struct DiscoveryView: View {
    
    @State var user: String = ""
    @State var image: Image = Image("fallback")
    @State var id: String = ""
    @State var currentDownload = 0.0
    @State var downloadDone = false
    @State var timePosted: Double = 0.0
    @State var liked = false
    @State var likes: Int

    var body: some View {
        ZStack {
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
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                        if !downloadDone {
                            VStack {
                                Spacer()
                                ProgressView(value: currentDownload, total: 100.0)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 12)
            .onAppear {
                getImage()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button {
                            simpleSuccess()
                            liked.toggle()
                        } label: {
                            Image(systemName: liked ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 38, height: 38)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        Text(String(liked ? likes + 1 : likes))
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(Color.white)
                    }
                }
            }
            .padding()
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
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(likes: 12)
    }
}
