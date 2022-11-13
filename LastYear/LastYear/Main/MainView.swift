//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseAnalytics

struct MainView: View {
    
    @EnvironmentObject var authService: AuthService
    
    var networkMonitor = NetworkMonitor()
    @State var selection = 2

    var friendsViewModel = FriendsViewModel()
    var content: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            TabView(selection: $selection) {
                FriendsView()
                    .environmentObject(friendsViewModel)
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Friends", systemImage: "person.3")
                    }
                    .tag(0)
                    .badge(AuthService.shared.loggedInUser?.friendRequests.count ?? 0)
                
                DiscoverView()
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Discover", systemImage: "magnifyingglass")
                    }
                    .tag(1)

                FeedView()
                    .environmentObject(friendsViewModel)
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(2)

                MemoriesView()
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Memories", systemImage: "photo")
                    }
                    .tag(3)

                ProfileView()
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(4)
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }
}

extension UIImage {
    func addFilter(filter: FilterType) -> UIImage {
        guard filter != .none else { return self }
        let filter = CIFilter(name: filter.rawValue)
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        //Return the image
        return UIImage(cgImage: cgImage!)
    }
}

enum FilterType: String {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer =  "CIPhotoEffectTransfer"
    case none = ""
}
