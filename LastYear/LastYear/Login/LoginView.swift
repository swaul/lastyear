//
//  LoginView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import LocalAuthentication

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
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            TextField(text: $email) {
                Text("example@mail.com")
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            Text("Password")
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            HStack {
                if showPassword {
                    TextField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                } else {
                    SecureField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
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
        .onAppear {
            getPasswordFromKeychain()
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
    
    func getPasswordFromKeychain() {
        do {
            let credentials = try CredentialsHandler.getPassword()
            tryBiometricAuthentication(password: credentials.password, email: credentials.email)
        } catch let error {
            print("[LOG] - Failed to get Credentials from Keychain")
        }
    }
    
    func tryBiometricAuthentication(password: String, email: String) {
      // 1
      let context = LAContext()
      var error: NSError?

      // 2
      if context.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &error) {
        // 3
        let reason = "Authenticate to unlock your note."
        context.evaluatePolicy(
          .deviceOwnerAuthenticationWithBiometrics,
          localizedReason: reason) { authenticated, error in
          // 4
          DispatchQueue.main.async {
            if authenticated {
              // 5
                self.email = email
                self.password = password
                self.login()
            } else {
              // 6
              if let errorString = error?.localizedDescription {
                print("Error in biometric policy evaluation: \(errorString)")
              }
            }
          }
        }
      } else {
        // 7
        if let errorString = error?.localizedDescription {
          print("Error in biometric policy evaluation: \(errorString)")
        }
      }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
