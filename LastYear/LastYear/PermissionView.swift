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
    
   var authorized: Bool {
       let status = PHPhotoLibrary.authorizationStatus()
       return status == .authorized
   }
    
    var body: some View {
        if !authorized {
            VStack {
                Spacer()
                Text("Bitte gib zugriff auf alle Bilder!")
                    .onAppear {
                        requestAccess()
                    }
            }
        } else {
            ContentView()
        }
    }
    
    func requestAccess() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    print("Access")
                } else {
                    fatalError()
                }
            })
        }
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
