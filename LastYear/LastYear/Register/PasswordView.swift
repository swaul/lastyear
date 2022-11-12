//
//  PasswordView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseAnalytics

struct PasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var password: String = ""
    @State var showPassword: Bool = false
    @State var appTrackingAccepted: Bool = false
    @State var termsAndConditionsAccepted: Bool = false
    
    var email: String
    var userName: String
    
    var isValidPassword: Bool {
        password.count >= 8
    }
    
    var buttonEnabled: Bool {
        print("valid pw", isValidPassword)
        print("termsAndConditions Accepted", termsAndConditionsAccepted)
        return isValidPassword && termsAndConditionsAccepted
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set your Password")
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            HStack {
                if showPassword {
                    TextField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                } else {
                    SecureField(text: $password) {
                        Text("Password")
                    }
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
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
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "eye")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color("primary"))
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("Agreements:")
                .font(Font.custom("Poppins-Bold", size: 16))
                .foregroundColor(.white)
            
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
            
            HStack {
                Button {
                    termsAndConditionsAccepted.toggle()
                } label: {
                    Image(systemName: termsAndConditionsAccepted ? "square.fill" : "square")
                        .foregroundColor(Color("primary"))
                }
                HStack(spacing: 0) {
                    Text("Yes, I agree to ")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(.leading)
                    Text("terms an conditions")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .underline()
                        .foregroundColor(Color("primary"))
                        .onTapGesture {
                            openTermsAndConditions()
                        }
                    Text("!")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical)
            
            Spacer()
            Button {
                createUser()
            } label: {
                Text("Register")
                    .font(Font.custom("Poppins-Bold", size: 18))
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(buttonEnabled ? Color("primary") : Color.gray)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(!buttonEnabled)
        }
        .padding()
        .navigationTitle("Password")
    }
    
    func openTermsAndConditions() {
        guard let url = URL(string: "https://www.google.com"),
                UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func createUser() {
        FirebaseHandler.shared.registerUser(email: email, password: password, userName: userName, appTracking: appTrackingAccepted) { result in
            switch result {
            case .failure(let error):
                print("[LOG] - Registring failed with error", error)
            case .success(let user):
                print("[LOG] - Register successful for", user)
                let credentials = Credentials(email: email, password: password)
                do {
                    try CredentialsHandler.setPassword(credentials: credentials)
                } catch let error {
                    print("[LOG] - Couldnt be saved to keychain", error.localizedDescription)
                }
                Analytics.setAnalyticsCollectionEnabled(appTrackingAccepted)
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
