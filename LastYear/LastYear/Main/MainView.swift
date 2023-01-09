//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseAnalytics

struct MainView: View {
    
    @StateObject var fotoService = PhotoService.shared
    @ObservedObject var authService = AuthService.shared
    
    var networkMonitor = NetworkMonitor()
    var friendsViewModel = FriendsViewModel()

    @State var selection = 2
    
    var content: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            TabView() {
                FriendsView()
                    .environmentObject(friendsViewModel)
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Friends", systemImage: "person.3")
                    }
                    .tag(0)
                    .badge(authService.requests)
                
//                DiscoverView()
//                    .environmentObject(networkMonitor)
//                    .environmentObject(friendsViewModel)
//                    .tabItem {
//                        Label("Discover", systemImage: "magnifyingglass")
//                    }
//                    .tag(1)
//
//                FeedView()
//                    .environmentObject(friendsViewModel)
//                    .environmentObject(networkMonitor)
//                    .tabItem {
//                        Label("Home", systemImage: "house")
//                    }
//                    .tag(2)
                
                HomeView()
                    .environmentObject(networkMonitor)
                    .environmentObject(friendsViewModel)
                    .tabItem {
                        Label("Home", systemImage: "magnifyingglass")
                    }
                    .tag(1)

                MemoriesView()
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Label("Memories", systemImage: "photo")
                    }
                    .tag(2)
                    .badge(fotoService.todaysPhotos)

                ProfileView()
                    .environmentObject(networkMonitor)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .task {
                if let userDefaults = UserDefaults(suiteName: appGroupName) {
                    if let asked = userDefaults.value(forKey: "permissionAsked") as? Bool, asked {
                        LocalNotificationCenter.shared.checkPermissionAndScheduleTomorrows()
                    }
                }
            }
            .onReceive(didLogout) { _ in
                selection = 2
            }
            .onAppear {
                ReviewHandler.requestReview()
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
