//
//  PermissionHandler.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import Foundation
import Photos
import UserNotifications

public class PermissionHandler: ObservableObject {
    
    @Published var photosAuthorized: Bool = false
    @Published var notificationsAuthorized: Bool = false
    
    @Published var notDetermined: Bool = false
    
    public static let shared = PermissionHandler()
    
    init() {
        self.photosAuthorized = getPhotoStatus() == .authorized
        getNotiStatus()
    }
    
    func getPhotoStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus()
    }
    
    func getNotiStatus() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationsAuthorized = settings.authorizationStatus == .authorized
                self?.notDetermined = settings.authorizationStatus == .notDetermined
            }
        }
    }
}
