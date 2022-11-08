////
////  AddFriendView.swift
////  LastYear
////
////  Created by Paul Kühnel on 27.10.22.
////
//
//import SwiftUI
//
//struct AddFriendView: View {
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//
//    @State var friend: String = ""
//    @State var errorShowing: Bool = false
//    @State var dialogShowing: Bool = false
//    
//    @State var error: String = ""
//    @State var friendFound: String = ""
//    
//    @State var color: Color = .white
//    
//    @State var friendFoundId: String = ""
//    
//    var body: some View {
//        VStack {
//            Text("Add a Friend!")
//            TextField(text: $friend) {
//                Text("Username")
//            }
//            .foregroundColor(color)
//            .textFieldStyle(.roundedBorder)
//            .textContentType(.username)
//            .padding(.horizontal)
//            .alert(isPresented: $errorShowing) {
//                Alert(title: Text("Fehler:"),
//                      message: Text(error),
//                      dismissButton: .cancel()
//                )
//            }
//            .alert(isPresented: $dialogShowing) {
//                Alert(title: Text("Found"),
//                      message: Text("add \(friendFound)?"),
//                      primaryButton: .default(Text("Add"), action: {
//                    sendFriendRequest()
//                }),
//                      secondaryButton: .cancel()
//                )
//            }
//            Button {
//                checkForName()
//            } label: {
//                Text("Check Name")
//                    .foregroundColor(.black)
//                    .padding()
//                    .background(Color.yellow)
//                    .cornerRadius(10)
//            }
//        }
//    }
//    
// 
//}
//
//struct AddFriendView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFriendView()
//    }
//}
