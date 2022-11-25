//
//  DiscoveryUpload.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation

public struct DiscoveryUpload: Hashable {
    let id: String
    var likes: [String]
    let timePosted: String
    let user: String
    
    var timePostedDate: Date? {
        Formatters.dateTimeFormatter.date(from: timePosted)
    }
    
    init(id: String, likes: [String], timePosted: String, user: String) {
        self.id = id
        self.likes = likes
        self.timePosted = timePosted
        self.user = user
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.likes = data["likes"] as! [String]
        self.timePosted = data["timePosted"] as! String
        self.user = data["user"] as! String
    }
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "likes": likes,
            "timePosted": timePosted,
            "user": user
        ]
        return data
    }
}
