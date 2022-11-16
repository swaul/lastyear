//
//  FriendsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI
import AlertToast

struct FriendsView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @State var selection = 0
    @State var searchText = ""
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                if networkMonitor.status == .disconnected {
                    ZStack {
                        Color.red.ignoresSafeArea()
                        NetworkError()
                    }
                    .transition(.move(edge: .top))
                    .frame(height: 40)
                } else {
                    Text("Friends")                                                .font(Font.custom("Poppins-Bold", size: 26))
                        .foregroundColor(.white)
                }
                TextField(text: $searchText) {
                    Text("Add a friend")
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($searchFocused)
                .onChange(of: friendsViewModel.userFound, perform: { userFound in
                    if userFound {
                        searchText = ""
                        searchFocused = false
                    }
                })
                .toast(isPresenting: $friendsViewModel.userFound, alert: {
                    AlertToast(displayMode: .hud, type: .regular, title: "Request Sent!", style: .style(backgroundColor: .green))
                }, completion: {
                    friendsViewModel.userFound = false
                })
                .alert(isPresented: $friendsViewModel.errorShowing) {
                    Alert(title: Text("Fehler:"),
                          message: Text(friendsViewModel.error),
                          dismissButton: .cancel()
                    )
                }
                VStack {
                    Picker("What is your favorite color?", selection: $selection) {
                        Text("Friends").tag(0)
                        Text("Recommended").tag(1)
                        Text("Requests").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                    switch selection {
                    case 2:
                        VStack {
                            Text("Friend requests")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            if friendsViewModel.friendRequestUsers.isEmpty {
                                Text("No friend requests")
                                    .font(Font.custom("Poppins-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .onAppear {
                                        friendsViewModel.getFriendRequests()
                                    }
                                Spacer()
                            } else {
                                ScrollView {
                                    ForEach(friendsViewModel.friendRequestUsers, id: \.id) { user in
                                        FriendRequestRow(user: user)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                    }
                                    //                                .listStyle(.plain)
                                    //                                .scrollContentBackground(.hidden)
                                }
                            }
                        }
                    case 1:
                        VStack {
                            Text("Recommendations")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            if friendsViewModel.recommendations.isEmpty {
                                HStack(spacing: 0) {
                                    Text("No friends yet, ")
                                        .font(Font.custom("Poppins-Regular", size: 20))
                                        .foregroundColor(.white)
                                    Button {
                                        selection = 2
                                    } label: {
                                        Text("add some!")
                                            .font(Font.custom("Poppins-Bold", size: 20))
                                            .foregroundColor(.white)
                                            .underline()
                                    }
                                }
                                .onAppear {
                                    if friendsViewModel.recommendations.isEmpty {
                                        friendsViewModel.getFriends()
                                    }
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    ForEach(friendsViewModel.recommendations, id: \.id) { user in
                                        RecommendationRowView(user: user)
                                            .environmentObject(friendsViewModel)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                    default:
                        VStack {
                            Text("Your Friends")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            if friendsViewModel.friends.isEmpty {
                                HStack(spacing: 0) {
                                    Text("No friends yet, ")
                                        .font(Font.custom("Poppins-Regular", size: 20))
                                        .foregroundColor(.white)
                                    Button {
                                        selection = 2
                                    } label: {
                                        Text("add some!")
                                            .font(Font.custom("Poppins-Bold", size: 20))
                                            .foregroundColor(.white)
                                            .underline()
                                    }
                                }
                                .onAppear {
                                    if friendsViewModel.friends.isEmpty {
                                        friendsViewModel.getFriends()
                                    }
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    ForEach(friendsViewModel.friends, id: \.id) { user in
                                        FriendRowView(user: user)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay {
                    if searchFocused {
                        ZStack {
                            Color("backgroundColor")
                                .ignoresSafeArea()
                                .onTapGesture {
                                    if searchText.count < 5 {
                                        searchFocused = false
                                    }
                                }
                            if searchText.count < 5 {
                                Text("Enter at least 5 letters")
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white)
                            } else {
                                VStack {
                                    HStack {
                                        Text(searchText)
                                            .font(Font.custom("Poppins-Bold", size: 16))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button {
                                            friendsViewModel.checkForName(name: searchText)
                                        } label: {
                                            Text("Add")
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .foregroundColor(.white)
                                                .padding(4)
                                                .background(Color("gray"))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .padding()
                                    .background(.red)
                                    Spacer()
                                        .onTapGesture {
                                            searchFocused = false
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
