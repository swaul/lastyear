//
//  NotificationCenter.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.09.22.
//

import Foundation
import UserNotifications
import Photos

class NotificationCenter: ObservableObject {
    
    static let shared = NotificationCenter()
    
    @Published var center = UNUserNotificationCenter.current()
    
    func scheduleFirst() {
        let content = UNMutableNotificationContent()
        content.title = "Feed the cat"
        content.subtitle = "It looks hungry"
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        center.add(request)
    }
    
    func scheduleTomorrows() {
        center.getPendingNotificationRequests { requests in
            if requests.isEmpty {
                self.scheduleTomorrowsWithFotos()
                
            }
        }
    }
    
    func scheduleTomorrowsWithFotos() {
        let dateOneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now)
        let dateTomorrowOYA = Calendar.current.date(byAdding: .day, value: 1, to: dateOneYearAgo!)
        guard let lastYearTomorrow = dateTomorrowOYA else { return }
                
        let oneBeforeLastYear = Calendar.current.date(byAdding: .day, value: -1, to: lastYearTomorrow)!.endOfDay
        let oneAfterLastYear = Calendar.current.date(byAdding: .day, value: 1, to: lastYearTomorrow)!.startOfDay
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", oneBeforeLastYear as NSDate, oneAfterLastYear as NSDate)
        
        let content = UNMutableNotificationContent()
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        content.title = "You have \(results.count) pictures to look back on from \(Formatters.dateFormatter.string(from: lastYearTomorrow))"
        content.subtitle = "Take a look and share it with your friends!"
        content.sound = UNNotificationSound.default
        
        let today = Date.now
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let lastYearTomorrowWithHour = Calendar.current.date(bySetting: .hour, value: 12, of: tomorrow)!
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: lastYearTomorrowWithHour)

        // show this notification five seconds from now
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        center.add(request)
    }
}
