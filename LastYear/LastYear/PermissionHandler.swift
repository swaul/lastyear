//
//  PermissionHandler.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import Foundation
import Photos

public class PermissionHandler: ObservableObject {
    
    @Published var authorized: Bool = false
    
    public static let shared = PermissionHandler()
    
    init() {
        self.authorized = getStatus() == .authorized
    }
    
    func getStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus()
    }
    
}
