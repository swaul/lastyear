//
//  EmailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct EmailView: View {
    
    @State var email: String = ""
    var username: String
    
    var isValidEmail: Bool {
        if email.count > 100 {
            return false
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // short format
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Benutzernamen erstellen")
                .font(Font.custom("Poppins-Bold", size: 14))
                .foregroundColor(.white)
            TextField(text: $email) {
                Text("E-Mail")
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            NavigationLink {
                PasswordView(email: email, userName: username)
            } label: {
                Text("Continue")
                    .font(Font.custom("Poppins-Bold", size: 18))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(isValidEmail ? Color("primary") : Color.gray)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(!isValidEmail)
            Spacer()
        }
        .padding()
        .navigationTitle("Email")
    }
}

struct EmailView_Previews: PreviewProvider {
    static var previews: some View {
        EmailView(username: "Beispiel")
    }
}
