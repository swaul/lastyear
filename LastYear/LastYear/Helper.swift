import Foundation
import SwiftUI
import OSLog

let appGroupName = "group.com.lichtenberg.lastyear"
let imagesGroupName = "images.com.lichtenberg.lastyear"
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
        if let userDefaults = UserDefaults(suiteName: imagesGroupName) {
            if let imageData = userDefaults.object(forKey: key) as? Data,
               let image = UIImage(data: imageData) {
                os_log("FOUND THE IMAGE %{public}@", log: OSLog.default, type: .error, key)
                return image
            } else {
                os_log("DID NOT FIND THE IMAGE %{public}@", log: OSLog.default, type: .error, key)
                return UIImage(named: "fallback")!
            }
        } else {
            os_log("DID NOT FIND THE IMAGE %{public}@", log: OSLog.default, type: .error, key)
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
        if let defaults = UserDefaults(suiteName: imagesGroupName) {
            for id in ids {
                defaults.removeObject(forKey: id)
            }
        }
    }
}
