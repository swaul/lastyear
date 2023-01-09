//
//  HomeView.swift
//  LastYear
//
//  Created by Paul Kühnel on 09.01.23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @State private var favoriteColor = 0
    
    @State var discovery: Bool = true
    
    var body: some View {
        ZStack {
            
            if discovery {
                DiscoverView()
                    .environmentObject(networkMonitor)
                    .environmentObject(friendsViewModel)
                    .tabItem {
                        Label("Discover", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                    .transition(.move(edge: .leading))
            } else {
                FeedView()
                    .environmentObject(friendsViewModel)
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(2)
                    .transition(.move(edge: .trailing))
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
                            .opacity(friendsViewModel.loading ? 0.0 : 1.0 )
                        //                            .overlay(Color("backgroundColor").opacity(friendsViewModel.loading ? 1.0 : 0.0 ))
                        if friendsViewModel.loading {
                            ProgressView()
                        }
                    }
                    .padding(2)
                    .background(Color("backgroundColor"))
                    .cornerRadius(8)
                    
                    Picker("", selection: $favoriteColor) {
                        Text("Discovery").tag(0)
                        Text("Friends").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 32)
                    .onChange(of: favoriteColor) { newValue in
                        withAnimation {
                            discovery = newValue == 0
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
