//
//  NotificationPermissionView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.09.22.
//

import SwiftUI

struct NotificationPermissionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    @ObservedObject var permissionHandler = PermissionHandler.shared
    
    var body: some View {
        VStack {
            Text("Please give notification permissions!")
                .font(Font.custom("Poppins-Bold", size: 24))
                .foregroundColor(.white)
            Button {
                requestNotiAccess()
            } label: {
                Text("Decide!")
                    .padding()
            }
        }
    }
    
    func requestNotiAccess() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                PermissionHandler.shared.notDetermined = false
                presentationMode.wrappedValue.dismiss()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView()
    }
}
