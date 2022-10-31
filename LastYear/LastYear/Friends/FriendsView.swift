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
    
    @State var images: [Image] = []
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    LogoView(size: 35)
                    Spacer()
                    Menu {
                        Button("Add new Friend", action: addFriend)
                        Button("Friend Requests", action: friendRequests)
                            .badge(AuthService.shared.loggedInUser?.friendRequests.count ?? 0)
                        Button("Friends", action: showFriends)
                    } label: {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .sheet(isPresented: $addFriendShowing) {
                    if #available(iOS 16, *) {
                        AddFriendView()
                            .presentationDetents([.fraction(0.3)])
                    } else {
                        AddFriendView()
                    }
                }
                .sheet(isPresented: $friendRequestsShwoing) {
                    if #available(iOS 16, *) {
                        VStack {
                            Text("Friend requests")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            if friendRequestUsers.isEmpty {
                                Text("No friend requests")
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .onAppear {
                                        getFriendRequests()
                                    }
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
                                        .buttonStyle(.plain)
                                        .padding(.horizontal)
                                        Button {
                                            denyRequest(user: user.id)
                                        } label: {
                                            Text("Deny")
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .listStyle(.plain)
                                .onAppear {
                                    getFriendRequests()
                                }
                            }
                        }
                        .presentationDetents([.fraction(0.3), .large])
                    } else {
                        VStack {
                            Text("Friend requests")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            if friendRequestUsers.isEmpty {
                                Text("No friend requests")
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .onAppear {
                                        getFriendRequests()
                                    }
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
                                        .buttonStyle(.plain)
                                        .padding(.horizontal)
                                        Button {
                                            denyRequest(user: user.id)
                                        } label: {
                                            Text("Deny")
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .listStyle(.plain)
                                .onAppear {
                                    getFriendRequests()
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showFriendList) {
                    if #available(iOS 16, *) {
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
                                .onAppear {
                                    getFriends()
                                }
                                Spacer()
                            } else {
                                List(friends, id: \.id) { user in
                                    HStack {
                                        Text(user.userName)
                                    }
                                }
                                .onAppear {
                                    getFriends()
                                }
                            }
                        }
                        .presentationDetents([.fraction(0.3), .large])
                    } else {
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
                                .onAppear {
                                    getFriends()
                                }
                                Spacer()
                            } else {
                                List(friends, id: \.id) { user in
                                    HStack {
                                        Text(user.userName)
                                    }
                                }
                                .onAppear {
                                    getFriends()
                                }
                            }
                        }
                    }
                }
                Spacer()
                    .onAppear {
                        subscribeToFriends()
                        getFriendRequests()
                        getFriends()
                    }
                if friends.isEmpty {
                    Text("No friends")
                    Spacer()
                } else {
                    VStack {
                        Text("Your friends' memories:")
                            .font(Font.custom("Poppins-Regular", size: 24))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        TabView {
                            ForEach(friends, id: \.id) { friend in
                                if let time = friend.sharedLastYear,
                                   !time.isEmpty,
                                   let date = Formatters.dateTimeFormatter.date(from: time) {
                                    let interval = Date.now.timeIntervalSince(date)
                                    let twentyFourHours: TimeInterval = 60 * 60 * 24
                                    let intervalInHours = Int((interval / 60 / 60).rounded())
                                    if interval < twentyFourHours {
                                        FriendLastYear(user: friend.userName, id: friend.id, timePosted: "\(intervalInHours)h ago")
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
        }
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
            case .success(_):
                print("denied!")
                AuthService.shared.loggedInUser?.friendRequests.removeAll(where: { $0 == user })
                getFriendRequests()
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
                AuthService.shared.loggedInUser?.friendRequests.removeAll(where: { $0 == user })
                friendRequestUsers.removeAll()
                getFriendRequests()
                getFriends()
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
                withAnimation {
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
            case .success(let users):
                withAnimation {
                    self.friends = users
                }
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

extension Optional where Wrapped == String {

    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }

}
