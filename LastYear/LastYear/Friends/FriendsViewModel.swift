//
//  FriendsViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation
import SwiftUI

class FriendsViewModel: ObservableObject {
    
    @Published var friendRequestUsers: [LYUser] = []
    @Published var friends: [LYUser] = []
    @Published var recommendations: [LYUser] = []
    @Published var error: String = ""
    @Published var errorShowing: Bool = false
    @Published var userFound = false
    
    init() {        
        subscribeToFriends()
        getFriendRequests()
        getFriends()
    }
    
    func subscribeToFriends() {
        guard let id = AuthService.shared.loggedInUser?.id else { return }
        FirebaseHandler.shared.subscribeToFriends(from: id) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let user):
                AuthService.shared.logIn(user: user)
            }
        }
    }
    
    func denyRequest(user: String) {
        guard let id = AuthService.shared.loggedInUser?.id else { return }
        withAnimation {
            friendRequestUsers.removeAll(where: { $0.id == id })
        }
        FirebaseHandler.shared.denyRequest(from: user, by: id) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self.simpleError()
            case .success(_):
                print("denied!")
                self.simpleSuccess()
                AuthService.shared.loggedInUser?.friendRequests.removeAll(where: { $0 == user })
                self.getFriendRequests()
            }
        }
    }
    
    func acceptRequest(by user: String) {
        guard let id = AuthService.shared.loggedInUser?.id else { return }
        FirebaseHandler.shared.acceptRequest(from: user, by: id) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                print("added!")
                self.getFriendRequests()
                self.getFriends()
            }
        }
    }
    
    func sendFriendRequest(to user: String) {
        guard let sender = AuthService.shared.loggedInUser else { return }
        FirebaseHandler.shared.sendFriendRequest(to: user, from: sender.id) { result in
            switch result {
            case .success(_):
                self.simpleSuccess()
                self.recommendations.removeAll(where: { $0.id == user })
                print("Sent!")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func checkForName(name: String) {
        FirebaseHandler.shared.checkForName(id: name) { result in
            switch result {
            case .failure(let error):
                self.error = error.localizedDescription
                self.errorShowing = true
                self.simpleError()
            case .success(let user):
                self.simpleSuccess()
                self.userFound = true
                self.sendFriendRequest(to: user.id)
            }
        }
    }
    
    func getFriendRequests() {
        guard
            let user = AuthService.shared.loggedInUser,
            let ids = AuthService.shared.loggedInUser?.friendRequests,
                !ids.isEmpty
        else { return }
        FirebaseHandler.shared.getUsers(by: ids) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(var users):
                withAnimation {
                    users.removeAll(where: { $0.id == user.id })
                    self.friendRequestUsers = users
                }
            }
        }
    }
    
    func getFriends() {
        guard let ids = AuthService.shared.loggedInUser?.friends, !ids.isEmpty else { return }
        FirebaseHandler.shared.getUsers(by: ids) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(var users):
                withAnimation {
                    self.friends = users
                    self.getRecommended()
                }
                AuthService.shared.loggedInUser?.friends = self.friends.map { $0.id }
            }
        }
    }
    
    func getRecommended() {
        guard !friends.isEmpty, let user = AuthService.shared.loggedInUser else { return }
        let myFriends = friends.map { $0.id }
        var theirFriends = friends.flatMap { $0.friends }
        
        theirFriends.removeAll(where: { myFriends.contains($0) })
        let unique = Array(Set(theirFriends))
        FirebaseHandler.shared.getUsers(by: unique) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(var users):
                withAnimation {
                    users.removeAll(where: { $0.id == user.id })
                    self.recommendations = users
                }
            }
        }
    }
    
    func simpleError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
