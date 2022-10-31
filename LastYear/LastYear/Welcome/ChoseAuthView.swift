//
//  AuthView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct ChoseAuthView: View {
    
    @State var username: String = ""
    @State var login: Bool = false
    @State var error: Bool = false
    @State private var selection: String? = nil
        
    var continueDisabled: Bool {
        username.count < 5 || error
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Create username")
                        .font(Font.custom("Poppins-Bold", size: 14))
                        .foregroundColor(.white)
                    TextField(text: $username) {
                        Text("Username")
                    }
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(error ? .red : .white)
                    .onChange(of: username, perform: { newValue in
                        error = false
                    })
                    if error {
                        Text("Name is already taken")
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.red)
                    }
                    NavigationLink(destination: EmailView(username: username), tag: "email", selection: $selection) {
                        EmptyView()
                    }
                    
                    Spacer()
                }
                .padding()
                
                LogoView(size: 15)
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
                
                Button {
                    checkName()
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
            }
            .navigationTitle("Username")
        }
    }
    
    func checkName() {
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        FirebaseHandler.shared.checkField(id: "userName", name: username.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let users):
                if users.isEmpty {
                    selection = "email"
                    print("did not find", username)
                } else {
                    error = true
                    print("found", users)
                }
            }
        }
    }
}

struct ChoseAuthView_Previews: PreviewProvider {
    static var previews: some View {
        ChoseAuthView()
    }
}
