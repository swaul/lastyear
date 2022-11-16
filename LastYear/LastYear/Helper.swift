import Foundation
import SwiftUI
import OSLog

let appGroupName = "group.com.lichtenberg.lastyear"
let userDefaultsPhotosKey = "photos"

struct Helper {
    
    static func getImageIdsFromUserDefault() -> [String] {
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsPhotosKey) {
                let ids = try! JSONDecoder().decode([String].self, from: data)
                print("[saved images]", ids.count)
                return ids
            }
        }
        
        return [String]()
    }
    
    static func getImageFromUserDefaults(key: String) -> UIImage {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let imageData = userDefaults.object(forKey: key) as? Data,
               let image = UIImage(data: imageData) {
                return image
            } else {
                return UIImage(named: "fallback")!
            }
        } else {
            return UIImage(named: "fallback")!
        }
    }
    
    static func removeAll() {
        if let defaults = UserDefaults(suiteName: appGroupName) {
            removeAllImages(ids: getImageIdsFromUserDefault())
            defaults.removeObject(forKey: userDefaultsPhotosKey)
        }
    }
    
    static func removeAllImages(ids: [String]) {
        if let defaults = UserDefaults(suiteName: appGroupName) {
            for id in ids {
                defaults.removeObject(forKey: id)
            }
        }
    }
}

extension Date {
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
