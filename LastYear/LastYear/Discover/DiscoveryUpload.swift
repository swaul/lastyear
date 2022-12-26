//
//  DiscoveryUpload.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation

public struct Reaction: Decodable, Hashable, Identifiable, Equatable {

    public let id: String
    public let reaction: String
    public var user: String
    
    init(id: String, reaction: String, user: String) {
        self.id = id
        self.reaction = reaction
        self.user = user
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.reaction = data["reaction"] as! String
        self.user = data["user"] as! String
    }
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "reaction": reaction,
            "user": user
        ]
        return data
    }
    
    public static func == (lhs: Reaction, rhs: Reaction) -> Bool {
        lhs.id == rhs.id
    }
}

public struct DiscoveryUpload: Hashable {
    let id: String
    var likes: [String]
    let timePosted: String
    let user: String
    var reactions: [Reaction]
    let description: String?
    
    var timePostedDate: Date? {
        Formatters.dateTimeFormatter.date(from: timePosted)
    }
    
    init(id: String, likes: [String], timePosted: String, user: String, reactions: [Reaction], description: String?) {
        self.id = id
        self.likes = likes
        self.timePosted = timePosted
        self.user = user
        self.reactions = reactions
        self.description = description
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.likes = data["likes"] as! [String]
        self.timePosted = data["timePosted"] as! String
        self.user = data["user"] as! String
        self.description = data["description"] as? String
        if let reactions = data["reactions"] as? [[String: Any]] {
            self.reactions = reactions.map { Reaction(data: $0) }
        } else {
            self.reactions = []
        }
    }
    
    func toData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "likes": likes,
            "timePosted": timePosted,
            "user": user
        ]
        
        if let description, !description.isEmpty, !description.isWhiteSpace {
            data["description"] = description
        }
        return data
    }
}

extension String {
    var isWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
