//
//  LastYearApp.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct LastYearApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var authService = AuthService.shared
    
    @State var loading: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if loading {
                LoadingView()
                    .onAppear {
                        checkLogin()
                    }
                    .preferredColorScheme(.dark)
            } else if authService.loggedIn {
                PermissionView()
                    .preferredColorScheme(.dark)
            } else {
                WelcomeView()
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    func checkLogin() {
        if let user = Auth.auth().currentUser {
            FirebaseHandler.shared.getUser(by: user.uid) { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    loaded()
                case .success(let lyUser):
                    authService.logIn(user: lyUser)
                    loaded()
                }
            }
        } else {
            authService.loggedIn = false
            loaded()
        }
    }
    
    func loaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loadingDone.send(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loading = false
            }
        }
    }
    
    func schedule() {
 
    }
    
}
