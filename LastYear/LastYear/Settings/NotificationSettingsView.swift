//
//  NotificationSettingsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 13.12.22.
//

import SwiftUI

struct NotificationSettingsView: View {
    var body: some View {
        HStack {
            Image(systemName: "lock")
            Text("privacy")
                .font(Font.custom("Poppins-Regular", size: 20))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color("gray"))
        .cornerRadius(8)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
