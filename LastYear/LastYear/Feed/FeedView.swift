//
//  FriendsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.10.22.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @ObservedObject var feedViewModel = FeedViewModel()
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            if feedViewModel.friendsMemories.isEmpty {
                Text("You need more friends..")
            } else {
                GeometryReader { reader in
                    
                    let screen = reader.frame(in: .global)
                    
                    TabView {
                        ForEach(0..<feedViewModel.friendsMemories.count, id: \.self) { index in
                            let discovery = feedViewModel.friendsMemories[index]
                            if let time = discovery.timePostedDate {
                                let interval = Date.now.timeIntervalSince(time)
                                let twentyFourHours: TimeInterval = 60 * 60 * 24
                                if interval < twentyFourHours {
                                    DiscoveryView(user: discovery.user, id: discovery.id, timePosted: interval, likes: discovery.likes, screen: screen)
                                        .environmentObject(friendsViewModel)
                                        .onAppear {
                                            if index == 0 && index == feedViewModel.friendsMemories.count {
                                                feedViewModel.getNextDiscoveries()
                                            } else if index != 0 && index % 9 == 0 {
                                                feedViewModel.getNextDiscoveries()
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .rotationEffect(Angle(degrees: 90), anchor: .topLeading)
                    .frame(width: screen.height, height: screen.width)
                    .offset(x: screen.width)
                }
            }
            VStack(spacing: 0) {
                if networkMonitor.status == .disconnected {
                    ZStack {
                        Color.red.ignoresSafeArea()
                        NetworkError()
                    }
                    .transition(.move(edge: .top))
                    .frame(height: 40)
                } else {
                    ZStack {
                        Image("logoSmall")
                            .padding(2)
                            .background(Color("backgroundColor"))
                            .cornerRadius(8)
                            .overlay(Color("backgroundColor").opacity(friendsViewModel.loading ? 1.0 : 0.0 ))
                        if friendsViewModel.loading {
                            ProgressView()
                        }
                    }
                    .padding(2)
                    .background(Color("backgroundColor"))
                    .cornerRadius(8)
                }
                Spacer()
            }
        }
    }
    
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

extension Optional where Wrapped == String {
    
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
    
}
