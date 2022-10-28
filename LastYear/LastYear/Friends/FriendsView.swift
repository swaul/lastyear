//
//  FriendsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.10.22.
//

import SwiftUI

struct FriendsView: View {
    
    @State var addFriendShowing: Bool = false
    @State var friendRequestsShwoing: Bool = false
    @State var showFriendList: Bool = false
    
    @State var friendRequestUsers: [LYUser] = []
    @State var friends: [LYUser] = []
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                LogoView(size: 35)
                Spacer()
                Menu("Options") {
                    Button("Add new Friend", action: addFriend)
                    Button("Friend Requests", action: friendRequests)
                        .badge(AuthService.shared.loggedInUser?.friendRequests.count ?? 0)
                    Button("Friends", action: showFriends)
                }
            }
            .sheet(isPresented: $addFriendShowing) {
                AddFriendView()
                    .presentationDetents([.fraction(0.3)])
            }
            .sheet(isPresented: $friendRequestsShwoing) {
                VStack {
                    Text("Friend requests")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                    if friendRequestUsers.isEmpty {
                        Text("No friend requests")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        List(friendRequestUsers, id: \.id) { user in
                            HStack {
                                Text(user.userName)
                                Spacer()
                                Button {
                                    acceptRequest(by: user.id)
                                } label: {
                                    Text("Add")
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal)
                                Button {
                                    denyRequest(user: user.id)
                                } label: {
                                    Text("Deny")
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.fraction(0.3), .large])
            }
            .sheet(isPresented: $showFriendList) {
                VStack {
                    Text("Your Friends")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                    if friends.isEmpty {
                        HStack(spacing: 0) {
                            Text("No friends yet, ")
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.white)
                            Button {
                                showFriendList = false
                                addFriend()
                            } label: {
                                Text("add some!")
                                    .font(Font.custom("Poppins-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        Spacer()
                    } else {
                        List(friends, id: \.id) { user in
                            HStack {
                                Text(user.userName)
                            }
                        }
                    }
                }
                .presentationDetents([.fraction(0.3), .large])
            }
            Spacer()
            Text("Hello, World!")
                .onAppear {
                    getFriendRequests()
                    getFriends()
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
            case .success(_):
                print("denied!")
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
                getFriends()
                AuthService.shared.loggedInUser?.friendRequests.removeAll(where: { $0 == user })
            }
        }
    }
    
    func addFriend() {
        addFriendShowing = true
    }
    
    func friendRequests() {
        friendRequestsShwoing = true
    }
    
    func showFriends() {
        showFriendList = true
    }
    
    func getFriendRequests() {
        guard let ids = AuthService.shared.loggedInUser?.friendRequests, !ids.isEmpty else { return }
        FirebaseHandler.shared.getUsers(by: ids) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let users):
                self.friendRequestUsers = users
            }
        }
    }
    
    func getFriends() {
        guard let ids = AuthService.shared.loggedInUser?.friends, !ids.isEmpty else { return }
        FirebaseHandler.shared.getUsers(by: ids) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let users):
                self.friends = users
                AuthService.shared.loggedInUser?.friends = friends.map { $0.id }
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
