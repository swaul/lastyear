//
//  SettingsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.09.22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var userService = AuthService.shared
    
    @State var logoutDialogShowing: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Text("Hallo \(userService.loggedInUser?.userName ?? "")")
                        .font(Font.custom("Poppins-Regular", size: 24))
                        .foregroundColor(.white)
                    Button {
                        logoutDialogShowing = true
                    } label: {
                        Text("Logout")
                            .font(Font.custom("Poppins-Regular", size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .alert(isPresented: $logoutDialogShowing) {
                    Alert(title:Text("Do you want to log out?"),
                          primaryButton: .destructive(Text("Logout")),
                          secondaryButton: .cancel())
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func logout() {
        FirebaseHandler.shared.logout { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success():
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
