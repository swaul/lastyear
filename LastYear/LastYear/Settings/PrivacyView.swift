//
//  PrivacyView.swift
//  LastYear
//
//  Created by Paul Kühnel on 29.09.22.
//

import SwiftUI

struct PrivacyView: View {
    
    @ObservedObject var authService = AuthService.shared
    
    init() {
        appTrackingAccepted = authService.loggedInUser?.appTracking ?? false
    }
    
    @State var appTrackingAccepted = false
    
    var body: some View {
        VStack {
            Text("Terms and conditions")
            HStack {
                Button {
                    appTrackingAccepted.toggle()
                } label: {
                    Image(systemName: appTrackingAccepted ? "square.fill" : "square")
                        .foregroundColor(Color("primary"))
                }
                .onDisappear {
                    FirebaseHandler.shared.changeUserTracking(to: appTrackingAccepted)
                }
                HStack {
                    Button {
                        appTrackingAccepted.toggle()
                    } label: {
                        Image(systemName: appTrackingAccepted ? "square.fill" : "square")
                            .foregroundColor(Color("primary"))
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("(Optional)")
                            .font(Font.custom("Poppins-Light", size: 12))
                            .foregroundColor(.white)
                        Text("You can track crashes and actions of my app!")
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                }
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
