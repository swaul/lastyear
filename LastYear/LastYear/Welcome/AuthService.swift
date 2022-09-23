//
//  AuthService.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import Foundation

public class AuthService: NSObject, ObservableObject {
    @Published public var loggedIn: Bool = false
    @Published public var loggedInUser: LYUser? = nil
    
    public static let shared = AuthService()
    
    func logIn(user: LYUser) {
        loggedInUser = user
        loggedIn = true
    }
    
    func logOut() {
        loggedInUser = nil
        loggedIn = false
    }
}
