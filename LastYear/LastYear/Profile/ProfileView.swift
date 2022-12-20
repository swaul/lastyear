//
//  ProfileView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI
import AWSS3
import AWSCore

struct ProfileView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var user = AuthService.shared.loggedInUser
    
    @State private var userViewShowing = false
    
    @State var uiImage: UIImage? = nil
    @State var noImage: Bool = false
    
    var options: [MenuSection] = optionset
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("Settings")
                    .font(Font.custom("Poppins-Bold", size: 26))
                    .foregroundColor(.white)
                List {
                    NavigationLink {
                        UserView(noImage: $noImage, uiImage: $uiImage, user: user ?? nil)
                    } label: {
                        userView
                    }
                    ForEach(options) { option in
                        Section(option.name) {
                            ForEach(option.items) { item in
                                if item.options.isEmpty {
                                    Button {
                                        print(item.name)
                                    } label: {
                                        Text(item.name)
                                            .font(Font.custom("Poppins-Regular", size: 20))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    NavigationLink {
                                        SettingsDetailView(item: item, user: user!)
                                    } label: {
                                        Text(item.name)
                                            .font(Font.custom("Poppins-Regular", size: 20))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 60)
                        .listRowBackground(Color.clear)
                    
                    Section {
                        Button {
                            print("Logout")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign out")
                                    .font(Font.custom("Poppins-Regular", size: 20))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.red.opacity(0.2))
                    }
                    Section {
                        Button {
                            print("Delete Acc")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Account")
                                    .font(Font.custom("Poppins-Regular", size: 20))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.red.opacity(0.2))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            if networkMonitor.status == .disconnected {
                ZStack {
                    Color.red.ignoresSafeArea()
                    VStack {
                        NetworkError()
                        Spacer()
                    }
                }
                .transition(.move(edge: .top))
                .frame(height: 40)
            }
        }
    }
    
    var userView: some View {
        if let user {
            return AnyView(
                HStack {
                    if let uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 68, height: 68)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .foregroundColor(.gray)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 68)
                            ProgressView()
                        }
                    }
                    Text("@\(user.userName)")
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                        .onAppear {
                            getImage()
                        }
                    Spacer()
                }
            )
            
        } else {
            return AnyView(
                HStack {
                    Text("Login")
                })
        }
    }
    
    func logout() {
        FirebaseHandler.shared.logout { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success():
                print("logged out")
                AuthService.shared.logOut()
            }
        }
    }
    
    func getImage() {
        guard let user = AuthService.shared.loggedInUser else { return }
        var id = user.id
        id += "profilePicture"
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let imageData = userDefaults.object(forKey: id) as? Data,
               let image = UIImage(data: imageData) {
                self.uiImage = image
            } else {
                loadImage()
            }
        } else {
            loadImage()
        }
    }
    
    func loadImage() {
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        guard let user else {
            noImage = true
            return
        }
        var id = user.id
        id += "profilePicture"
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else {
                noImage = true
                return
            }
            self.uiImage = UIImage(data: data)
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                if let jpegRepresentation = uiImage?.jpegData(compressionQuality: 0.75) {
                    userDefaults.set(jpegRepresentation, forKey: id)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct MenuSection: Identifiable {
    var id: String
    var name: String
    var items: [MenuItem]
}

struct MenuItem: Equatable, Identifiable {
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var name: String
    var options: [Option]
}

class Option: Identifiable, ObservableObject {
    var id: String
    var name: String
    var description: String?
    var isDBStored: Bool
    var hasSwitch: Bool
    @State var isOn: Bool = false
    
    init(id: String, name: String, description: String?, hasSwitch: Bool, isDBStored: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.hasSwitch = hasSwitch
        self.isDBStored = isDBStored
    }
}

let optionset = [
    MenuSection(
        id: "settings",
        name: "Settings",
        items: [
            MenuItem(
                id: "notifications",
                name: "notifications",
                options: [
                    Option(
                        id: "notificationstatus",
                        name: "status",
                        description: "allow notifications",
                        hasSwitch: true,
                        isDBStored: false
                    )
                ]
            ),
            MenuItem(
                id: "privacy",
                name: "privacy",
                options: [
                    Option(
                        id: "apptracking",
                        name: "App tracking",
                        description: "This allows us to track crashes and actions of your app, to fix problems in upcoming updates!",
                        hasSwitch: true,
                        isDBStored: true
                    )
                ]
            )
        ]),
    MenuSection(
        id: "about",
        name: "About",
        items: [
            MenuItem(
                id: "rateLastYear",
                name: "rate LastYear",
                options: []
            ),
            MenuItem(
                id: "help",
                name: "help",
                options: []
            ),
            MenuItem(
                id: "aboutus",
                name: "about us",
                options: []
            ),
            MenuItem(
                id: "shareLastYear",
                name: "share LastYear",
                options: []
            ),
        ])
]
