//
//  PermissionView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import AVFoundation
import Photos
import UserNotifications

struct PermissionView: View {
    
    @ObservedObject var permission = PermissionHandler.shared
    
    @State var askForNotiShowing: Bool = false
    @State var permissionDeniedShowing: Bool = false
    
    var body: some View {
        if !permission.photosAuthorized {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        ZStack {
                            Image("stars2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                            VStack {
                                Image("rocket_tilted")
                                VStack(spacing: -4) {
                                    Text("Find")
                                        .font(Font.custom("Poppins-Bold", size: 48))
                                        .foregroundColor(Color.white)
                                    Text("Your")
                                        .font(Font.custom("Poppins-Bold", size: 48))
                                        .foregroundColor(Color("primary"))
                                    Text("Memories.")
                                        .font(Font.custom("Poppins-Bold", size: 48))
                                        .foregroundColor(Color.white)
                                }
                            }
                        }
                    }
                    Spacer()
                    HStack(spacing: 0) {
                        Text("Please grant the app access to ")
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundColor(Color.white)
                        Text("all")
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundColor(Color("primary"))
                        Text(" your photos!")
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundColor(Color.white)
                    }
                    Button {
                        requestPhotoAccess()
                    } label: {
                        Text("Lets find Photos")
                            .font(Font.custom("Poppins-Bold", size: 20))
                            .foregroundColor(Color("backgroundColor"))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding()
                .fullScreenCover(isPresented: $permissionDeniedShowing) {
                    ZStack {
                        Color("backgroundColor")
                            .ignoresSafeArea()
                        VStack {
                            Text("Please head to settings to grant access to all photos")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .foregroundColor(.white)
                            Button {
                                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                UIApplication.shared.open(url)
                            } label: {
                                Text("Settings")
                                    .font(Font.custom("Poppins-Bold", size: 24))
                                    .foregroundColor(Color("backgroundColor"))
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        } else if permission.notDetermined {
            NotificationPermissionView()
        } else {
            MainView()
        }
    }
    
    func requestPhotoAccess() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if !(photos == .authorized) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        permission.photosAuthorized = true
                    }
                } else if status == .denied {
                    permissionDeniedShowing = true
                } else {
                    DispatchQueue.main.async {
                        permission.photosAuthorized = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                permission.photosAuthorized = true
            }
        }
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
