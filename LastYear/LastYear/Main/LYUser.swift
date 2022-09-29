//
//  LYUser.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation
import FirebaseAuth

public struct LYUser {
    let id: String
    let email: String
    let userName: String
    let appTracking: Bool
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "email": email,
            "userName": userName,
            "appTracking": appTracking
        ]
        
        return data
    }
    
    public init(email: String, userName: String, id: String, appTracking: Bool) {
        self.userName = userName
        self.email = email
        self.id = id
        self.appTracking = appTracking
    }
    
    public init(user: FirebaseAuth.User, userName: String, appTracking: Bool) {
        self.id = user.uid
        self.userName = userName
        self.email = user.email ?? ""
        self.appTracking = appTracking
    }
    
    public init?(data: [String: Any]) {
        self.id = data["id"] as! String
        self.email = data["email"] as! String
        self.userName = data["userName"] as! String
        self.appTracking = data["appTracking"] as! Bool
    }
}
