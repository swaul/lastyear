import Foundation
import SwiftUI

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
            defaults.removeObject(forKey: userDefaultsPhotosKey)
        }
    }
}
