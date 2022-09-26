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
    
    @ObservedObject var permission = PermissionHandler()
    
    var body: some View {
        if !permission.authorized {
            VStack {
                Spacer()
                Text("Bitte gib zugriff auf alle Bilder!")
                    .onAppear {
                        permission.requestAccess()
                    }
            }
        } else {
            ContentView()
        }
    }
    
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
