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
        let today = Date.now
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        center.getPendingNotificationRequests { requests in
            let calendarNotis = requests.map { $0.trigger as? UNCalendarNotificationTrigger }
            let scheduled = calendarNotis.contains(where: {
                guard let date = $0?.nextTriggerDate() else { return false }
                return Calendar.current.isDate(date, inSameDayAs: tomorrow)
            })
            
            if !scheduled {
                self.scheduleTomorrowsWithFotos(tomorrow: tomorrow)
            }
        }
    }
    
    func scheduleTomorrowsWithFotos(tomorrow: Date) {
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
        guard results.count != 0 else { return }
        content.title = "You have \(results.count) pictures to look back on from \(Formatters.dateFormatter.string(from: lastYearTomorrow))"
        content.subtitle = "Take a look and share it with your friends!"
        content.sound = UNNotificationSound.default
        
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: tomorrow)
        components.hour = Int.random(in: 9...14)

        // show this notification five seconds from now
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        center.add(request)
    }
}
