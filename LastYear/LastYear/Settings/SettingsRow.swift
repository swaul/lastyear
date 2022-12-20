//
//  SettingsRow.swift
//  LastYear
//
//  Created by Paul Kühnel on 13.12.22.
//

import SwiftUI

struct SettingsRow: View {
    
    @ObservedObject var option: Option
    
    var user: LYUser
    @State var isOn: Bool = false
    
    var body: some View {
        if option.hasSwitch {
            VStack(alignment: .leading) {
                Toggle(isOn: $isOn) {
                    Text(option.name)
                        .font(Font.custom("Poppins-Regular", size: 20))
                        .foregroundColor(.white)
                }

                if let description = option.description {
                    Text(description)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .task {
                getOptionStatus()
            }
            .onChange(of: isOn) { newValue in
                setOptionStatus(value: newValue)
            }
        } else {
            VStack(alignment: .leading) {
                Text(option.name)
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                if let description = option.description {
                    Text(description)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    func getOptionStatus() {
        if option.id == "apptracking", let authService = AuthService.shared.loggedInUser {
            isOn = authService.appTracking
        }
        
        if let defaults = UserDefaults(suiteName: user.id), let item = defaults.value(forKey: option.id) as? Bool {
            print("found userdefault \(option.id):", item)
            isOn = item
        } else {
            isOn = false
        }
    }
    
    func setOptionStatus(value: Bool) {
        guard let defaults = UserDefaults(suiteName: user.id) else { return }
        defaults.setValue(value, forKey: option.id)
        print("set userdefault \(option.id):", value)
        if option.id == "apptracking" {
            FirebaseHandler.shared.changeUserTracking(to: value)
        }
    }
}
