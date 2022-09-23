//
//  LoginView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var email: String = ""
    @State var password: String = ""
    
    @State var showPassword: Bool = false
    
    var loginButtonDisabled: Bool {
        !isValidEmail || password.count < 8
    }
    
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
            Text("Email")
                .font(Font.custom("Poppins-Bold", size: 14))
                .foregroundColor(.black)
            TextField(text: $email) {
                Text("example@mail.com")
            }
            .textFieldStyle(.roundedBorder)
            Text("Password")
                .font(Font.custom("Poppins-Bold", size: 14))
                .foregroundColor(.black)
            HStack {
                if showPassword {
                    TextField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                } else {
                    SecureField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                }
                Button {
                    withAnimation {
                        showPassword.toggle()
                    }
                } label: {
                    if showPassword {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("primary"))
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "eye")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("primary"))
                            .cornerRadius(10)
                    }
                }
            }
            Button {
                login()
            } label: {
                Text("Continue")
                    .font(Font.custom("Poppins-Bold", size: 18))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(loginButtonDisabled ? Color.gray : Color("primary"))
                    .cornerRadius(10)
            }
            .padding()
            .disabled(loginButtonDisabled)
            Spacer()
        }
        .padding()
        .navigationTitle("Email")
    }
    
    func login() {
        FirebaseHandler.shared.loginUser(email: email, password: password) { result in
            switch result {
            case .failure(let error):
                print("[LOG] - Login failed with error", error)
            case .success(let user):
                print("[LOG] - User logged in with", user.email)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
