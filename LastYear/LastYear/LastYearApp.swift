//
//  LastYearApp.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

@main
struct LastYearApp: App {
    
    var loginRequired: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if loginRequired {
                WelcomeView()
            } else {
                ContentView()
            }
        }
    }
    
}
