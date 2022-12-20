//
//  LastYearApp.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import AWSCognitoIdentityProvider

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                if let asked = userDefaults.value(forKey: "permissionAsked") as? Bool, asked {
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: { _, _ in }
                    )
                }
            }
            
            
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
                                                                identityPoolId:"eu-central-1:b5033c3f-c7fb-484d-8707-d1404201007a")
        
        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                //            self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
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
                        UITabBar.appearance().isTranslucent = false
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
}
