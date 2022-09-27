//
//  AuthView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct ChoseAuthView: View {
        
    @State var username: String = ""
    @State var next: Bool = false
    @State var login: Bool = false
    
    var continueDisabled: Bool {
        username.count < 5
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Benutzernamen erstellen")
                        .font(Font.custom("Poppins-Bold", size: 14))
                        .foregroundColor(.white)
                    TextField(text: $username) {
                        Text("Username")
                    }
                    .textFieldStyle(.roundedBorder)
                    NavigationLink {
                        EmailView(username: username)
                    } label: {
                        Text("Continue")
                            .font(Font.custom("Poppins-Bold", size: 18))
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background(continueDisabled ? Color.gray : Color("primary"))
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(continueDisabled)
                    
                    Spacer()
                }
                .padding()
                
                HStack(alignment: .center, spacing: 2) {
                    Text("I already have an account.")
                        .font(Font.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.white)
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Login")
                            .font(Font.custom("Poppins-Bold", size: 12))
                            .foregroundColor(Color("primary"))
                    }
                }
                .padding(12)
                Spacer()
            }
            .navigationTitle("Username")
        }
    }
}

struct ChoseAuthView_Previews: PreviewProvider {
    static var previews: some View {
        ChoseAuthView()
    }
}
