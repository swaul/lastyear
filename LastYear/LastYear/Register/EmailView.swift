//
//  EmailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct EmailView: View {
    
    @State var email: String = ""
    
    @State var error: Bool = false
    @State private var selection: String? = nil
    
    @FocusState var textfieldfocus
    
    var username: String
    
    var isValidEmail: Bool {
        if error {
            return false
        }
        if email.count > 100 {
            return false
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // short format
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set Email")
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            TextField(text: $email) {
                Text("E-Mail")
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .foregroundColor(error ? .red : .white)
            .focused($textfieldfocus)
            .onChange(of: email, perform: { newValue in
                error = false
            })
            .onAppear {
                textfieldfocus = true
            }
            if error {
                Text("Email is already in use")
                    .font(Font.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.red)
            }
            Spacer()
            NavigationLink(destination: PasswordView(email: email, userName: username), tag: "password", selection: $selection) {
                EmptyView()
            }
            Button {
                checkMail()
            } label: {
                Text("Continue")
                    .font(Font.custom("Poppins-Bold", size: 18))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(isValidEmail ? Color("primary") : Color.gray)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(!isValidEmail)
        }
        .padding()
        .navigationTitle("Email")
    }
    
    func checkMail() {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        FirebaseHandler.shared.checkField(id: "email", name: email.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let users):
                if users.isEmpty {
                    selection = "password"
                    print("did not find", email)
                } else {
                    error = true
                    print("found", users)
                }
            }
        }
    }
}

struct EmailView_Previews: PreviewProvider {
    static var previews: some View {
        EmailView(username: "Beispiel")
    }
}
