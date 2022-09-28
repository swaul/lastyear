import Foundation
import SwiftUI

let appGroupName = "group.at.kuehnel.LastYear-test"
let userDefaultsPhotosKey = "photos"

struct Helper {
    
    static func getImageIdsFromUserDefault() -> [String] {
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsPhotosKey) {
                return try! JSONDecoder().decode([String].self, from: data)
            }
        }
        
        return [String]()
    }
    
    static func getImageFromUserDefaults(key: String) -> UIImage {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let imageData = userDefaults.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return UIImage(systemName: "photo.fill.on.rectangle.fill")!
    }
    
    static func removeAll() {
        let imageIds = getImageIdsFromUserDefault()
        if let defaults = UserDefaults(suiteName: appGroupName) {
            _ = imageIds.map {
                defaults.removeObject(forKey: $0)
            }
        }
    }
}
