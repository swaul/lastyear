//
//  ProfileView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI
import AWSS3
import AWSCore

struct ProfileView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var user = AuthService.shared.loggedInUser
    
    @State private var userViewShowing = false
    
    @State var uiImage: UIImage? = nil
    @State var noImage: Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("Settings")
                    .font(Font.custom("Poppins-Bold", size: 26))
                    .foregroundColor(.white)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        userView
                            .onTapGesture {
                                userViewShowing = true
                            }
                        settingsView
                            .padding(.vertical)
                        aboutView
                            .padding(.vertical)
                        Spacer(minLength: 32)
                        Button {
                            logout()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign out")
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.vertical)

                    }
                }
                .padding(.horizontal, 7)
                .sheet(isPresented: $userViewShowing) {
                    if let user = AuthService.shared.loggedInUser {
                        UserView(noImage: $noImage, uiImage: $uiImage, user: user)
                    }
                }
            }
            .padding(8)
            if networkMonitor.status == .disconnected {
                ZStack {
                    Color.red.ignoresSafeArea()
                    VStack {
                        NetworkError()
                     Spacer()
                    }
                }
                .transition(.move(edge: .top))
                .frame(height: 40)
            }
        }
    }
    
    var userView: some View {
        if let user {
            return AnyView(
                HStack {
                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 68, height: 68)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .foregroundColor(.gray)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 68)
                            ProgressView()
                        }
                    }
                    Text("@\(user.userName)")
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                        .onAppear {
                            getImage()
                        }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                    .padding()
                    .background(Color("gray"))
                    .cornerRadius(8)

            )
            
        } else {
            return AnyView(
                HStack {
                    Text("Login")
                })
        }
    }
    
    var settingsView: some View {
        VStack(alignment: .leading) {
            Text("SETTIINGS")
                .font(Font.custom("Poppins-Regular", size: 16))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "bell.badge")
                Text("notifications")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
            
            HStack {
                Image(systemName: "globe")
                Text("language")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
            
            HStack {
                Image(systemName: "lock")
                Text("privacy")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
        }
    }
    
    var aboutView: some View {
        VStack(alignment: .leading) {
            Text("ABOUT")
                .font(Font.custom("Poppins-Regular", size: 16))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "star")
                Text("rate LastYear")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
            
            HStack {
                Image(systemName: "questionmark.circle")
                Text("help")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
            
            HStack {
                Image(systemName: "info.circle")
                Text("about us")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
            
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("share LastYear")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color("gray"))
            .cornerRadius(8)
        }
    }

    func logout() {
        FirebaseHandler.shared.logout { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success():
                print("logged out")
                AuthService.shared.logOut()
            }
        }
    }
    
    func getImage() {
        guard let user = AuthService.shared.loggedInUser else { return }
        var id = user.id
        id += "profilePicture"
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let imageData = userDefaults.object(forKey: id) as? Data,
               let image = UIImage(data: imageData) {
                self.uiImage = image
            } else {
                loadImage()
            }
        } else {
            loadImage()
        }
    }
    
    func loadImage() {
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        guard let user else {
            noImage = true
            return
        }
        var id = user.id
        id += "profilePicture"
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else {
                noImage = true
                return
            }
            self.uiImage = UIImage(data: data)
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                if let jpegRepresentation = uiImage?.jpegData(compressionQuality: 0.75) {
                    userDefaults.set(jpegRepresentation, forKey: id)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
