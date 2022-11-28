//
//  DiscoveryUpload.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation

public struct Reaction: Decodable, Hashable, Identifiable {
    
    public let id: String
    public let reaction: String
    public var users: [String]
    
    init(id: String, reaction: String, users: [String]) {
        self.id = id
        self.reaction = reaction
        self.users = users
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.reaction = data["reaction"] as! String
        self.users = data["users"] as! [String]
    }
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "reaction": reaction,
            "users": users
        ]
        return data
    }
}

public struct DiscoveryUpload: Hashable {
    let id: String
    var likes: [String]
    let timePosted: String
    let user: String
    var reactions: [Reaction]
    
    var timePostedDate: Date? {
        Formatters.dateTimeFormatter.date(from: timePosted)
    }
    
    init(id: String, likes: [String], timePosted: String, user: String, reactions: [Reaction]) {
        self.id = id
        self.likes = likes
        self.timePosted = timePosted
        self.user = user
        self.reactions = reactions
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.likes = data["likes"] as! [String]
        self.timePosted = data["timePosted"] as! String
        self.user = data["user"] as! String
        if let reactions = data["reactions"] as? [Reaction] {
            self.reactions = reactions
        } else {
            self.reactions = []
        }
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
