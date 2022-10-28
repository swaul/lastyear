//
//  AddFriendView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.10.22.
//

import SwiftUI

struct AddFriendView: View {
    
    @State var friend: String = ""
    @State var errorShowing: Bool = false
    @State var dialogShowing: Bool = false
    
    @State var error: String = ""
    @State var friendFound: String = ""
    
    @State var color: Color = .white
    
    @State var friendFoundId: String = ""
    
    var body: some View {
        VStack {
            Text("Add a Friend!")
            TextField(text: $friend) {
                Text("Username")
            }
            .foregroundColor(color)
            .textFieldStyle(.roundedBorder)
            .textContentType(.username)
            .padding(.horizontal)
            .alert(isPresented: $errorShowing) {
                Alert(title: Text("Fehler:"),
                      message: Text(error),
                      dismissButton: .cancel()
                )
            }
            .alert(isPresented: $dialogShowing) {
                Alert(title: Text("Found"),
                      message: Text("add \(friendFound)?"),
                      primaryButton: .default(Text("Add"), action: {
                    sendFriendRequest()
                }),
                      secondaryButton: .cancel()
                )
            }
            Button {
                checkForName()
            } label: {
                Text("Check Name")
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
        }
    }
    
    func sendFriendRequest() {
        guard let sender = AuthService.shared.loggedInUser else { return }
        FirebaseHandler.shared.sendFriendRequest(to: friendFoundId, from: sender.id) { result in
            switch result {
            case .success(_):
                print("Sent!")
            case .failure(let error):
                self.color = .red
                self.error = error.localizedDescription
                self.errorShowing = true
            }
        }
    }
    
    func checkForName() {
        FirebaseHandler.shared.checkForName(id: friend) { result in
            switch result {
            case .failure(let error):
                self.color = .red
                self.error = error.localizedDescription
                self.errorShowing = true
            case .success(let user):
                self.color = .green
                self.friendFound = user.userName
                self.friendFoundId = user.id
                self.dialogShowing = true
            }
        }
    }
}

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView()
    }
}
