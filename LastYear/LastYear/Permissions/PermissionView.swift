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
            VStack {
                Spacer()
                Text("Please grant the app access to all your photos!")
                    .onAppear {
                        requestPhotoAccess()
                    }
                    .onTapGesture {
                        requestPhotoAccess()
                    }
                    .fullScreenCover(isPresented: $permissionDeniedShowing) {
                        VStack {
                            Text("You need to head to settings to grant access to all photos...")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .foregroundColor(.white)
                            Button {
                                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                UIApplication.shared.open(url)
                            } label: {
                                Text("Settings")
                                    .font(Font.custom("Poppins-Bold", size: 24))
                                    .padding()
                                    .backgroundStyle(Color.white)
                                    .foregroundColor(Color("backgroundColor"))
                            }
                        }
                        .padding(16)
                    }
            }
            .onChange(of: permission.photosAuthorized, perform: { newValue in
                if permission.notDetermined {
                    askForNotiShowing = true
                }
            })
            .onAppear {
                if permission.notDetermined {
                    askForNotiShowing = true
                }
            }
            .fullScreenCover(isPresented: $askForNotiShowing) {
                NotificationPermissionView()
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
