//
//  HomeView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @ObservedObject var viewModel = DiscoverViewModel()
    
    @State var text = ""
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
                .task {
                    viewModel.getDiscoveries()
                }
            if viewModel.discoveries.isEmpty && !viewModel.loading {
                Text("You need more friends..")
            } else {
                GeometryReader { reader in
                    
                    let screen = reader.frame(in: .global)
                    
                    TabView {
                        ForEach(0..<viewModel.discoveries.count, id: \.self) { index in
                            let discovery = viewModel.discoveries[index]
                            if let time = discovery.timePostedDate {
                                let interval = Date.now.timeIntervalSince(time)
                                let twentyFourHours: TimeInterval = 60 * 60 * 24
                                if interval < twentyFourHours {
                                    
                                    DiscoveryView(user: discovery.user, id: discovery.id, timePosted: interval, likes: discovery.likes, screen: screen, reactions: discovery.reactions)
                                        .environmentObject(friendsViewModel)
                                        .onAppear {
                                            if index == 0 && index == viewModel.discoveries.count {
                                                viewModel.getNextDiscoveries()
                                            } else if index != 0 && index % 9 == 0 {
                                                viewModel.getNextDiscoveries()
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
                            .opacity(viewModel.loading ? 0.0 : 1.0 )
                        //                            .overlay(Color("backgroundColor").opacity(viewModel.loading ? 1.0 : 0.0 ))
                        if viewModel.loading {
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
    
    var topView: some View {
        Text("Discovery")
            .font(Font.custom("Poppins-Regular", size: 24))
            .foregroundColor(.white)
            .padding(.vertical)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}

//                VStack(spacing: 0) {
//                    if networkMonitor.status == .disconnected {
//                        ZStack {
//                            Color.red.ignoresSafeArea()
//                            NetworkError()
//                        }
//                        .transition(.move(edge: .top))
//                        .frame(height: 40)
//                    } else {
//                        Image("logoSmall")
//                            .padding(.bottom)
//                    }

//            topView
//            if viewModel.loading {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                    Spacer()
//                }
//            } else {
//                Text("No more memories left...")
//                    .font(Font.custom("Poppins-Regular", size: 20))
//                    .foregroundColor(Color("gray"))
//                    .padding()
//                    .onAppear {
//                        viewModel.getNextDiscoveries()
//                    }
//            }
