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
    
    func toData() -> [String: Any] {
        let data = [
            "id": id,
            "email": email,
            "userName": userName
        ]
        
        return data
    }
    
    public init(email: String, userName: String, id: String) {
        self.userName = userName
        self.email = email
        self.id = id
    }
    
    public init(user: FirebaseAuth.User, userName: String) {
        self.id = user.uid
        self.userName = userName
        self.email = user.email ?? ""
    }
}
