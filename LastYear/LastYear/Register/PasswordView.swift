//
//  PasswordView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct PasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var password: String = ""
    @State var showPassword: Bool = false
    
    var email: String
    var userName: String
    
    var isValidPassword: Bool {
        password.count >= 8
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set your Password")
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
                createUser()
            } label: {
                Text("Register")
                    .font(Font.custom("Poppins-Bold", size: 18))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(isValidPassword ? Color("primary") : Color.gray)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(!isValidPassword)
            Spacer()
        }
        .padding()
        .navigationTitle("Password")
    }
    
    func createUser() {
        FirebaseHandler.shared.registerUser(email: email, password: password, userName: userName) { result in
            switch result {
            case .failure(let error):
                print("[LOG] - Registring failed with error", error)
            case .success(let user):
                print("[LOG] - Register successful for", user)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(email: "yo@yo.at", userName: "user1")
    }
}
