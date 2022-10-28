//
//  FriendLastYear.swift
//  LastYear
//
//  Created by Paul Kühnel on 28.10.22.
//

import SwiftUI
import FirebaseStorage

struct FriendLastYear: View {
    
    @State var user: String = ""
    @State var image: Image = Image("fallback")
    @State var sharedLastYear: String = ""
    
    var body: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("primary"), lineWidth: 3)
                )
                .padding()
            HStack {
                Text(user)
                Spacer()
            }
        }
        .onAppear {
            getImage()
        }
    }
    
    func getImage() {
        Storage.storage().reference().child("images/\(sharedLastYear)").getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let image = UIImage(data: data!) else { return }
                self.image = Image(uiImage: image)
            }
        }
    }
}

struct FriendLastYear_Previews: PreviewProvider {
    static var previews: some View {
        FriendLastYear()
    }
}
