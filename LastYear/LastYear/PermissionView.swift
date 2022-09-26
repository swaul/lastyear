//
//  PermissionView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import AVFoundation
import Photos

struct PermissionView: View {
    
    @ObservedObject var permission = PermissionHandler.shared
    
    @State var permissionDeniedShowing: Bool = false
    
    var body: some View {
        if !permission.authorized {
            VStack {
                Spacer()
                Text("Bitte gib zugriff auf alle Bilder!")
                    .onAppear {
                        requestAccess()
                    }
                    .onTapGesture {
                        requestAccess()
                    }
                    .fullScreenCover(isPresented: $permissionDeniedShowing) {
                        Text("Du musst in die einstellungen gehen und permissions für fotos geben....")
                    }
            }
        } else {
            MainView()
        }
    }
    
    func requestAccess() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if !(photos == .authorized) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        permission.authorized = true
                    }
                } else {
                    DispatchQueue.main.async {
                        permission.authorized = false
                    }
                }
            }
        } else if photos == .denied {
            let url = UIApplication.openSettingsURLString
        } else {
            DispatchQueue.main.async {
                permission.authorized = true
            }
        }
    }
    
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
