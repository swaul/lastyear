//
//  DiscoveriesView.swift
//  LastYear
//
//  Created by Paul Kühnel on 08.11.22.
//

import SwiftUI
import FirebaseStorage
import ImageViewer
import AWSS3
import AWSCore
import Shared

struct DiscoveryView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @Namespace var details
    
    @State var user: String = ""
    @State var userPP: Image? = nil
    @State var image: Image? = nil
    @State var id: String = ""
    @State var currentDownload = 0.0
    @State var downloadDone = false
    @State var timePosted: Double
    @State var liked = false
    @State var serverLiked = false
    @State var likes: [String]
    @State var showEmoji = false
    @State var selectedEmoji: Emoji? = nil
    @State var screen: CGRect
    @State var reactions: [Reaction]
    
    @State var searching: Bool = false
    
    @State var selectedDetent: PresentationDetent = .fraction(0.3)
    
    var likeImage: Image {
        return Image(systemName: likes.contains(where: { $0 == AuthService.shared.loggedInUser?.id ?? "" }) ? "heart.fill" : "heart")
    }
    
    @State var showDetail: Bool = false
    
    var body: some View {
        VStack {
            //            backgroundView
            userView
            
            ZStack {
                Color.white
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .foregroundColor(.gray)
                    ProgressView()
                }
            }
            .frame(width: getRect().width)
            .aspectRatio(0.8, contentMode: .fit)
            .cornerRadius(8)
            .onChange(of: selectedEmoji, perform: { newValue in
                guard let user = AuthService.shared.loggedInUser, let newValue else { return }
                FirebaseHandler.shared.changeReaction(selfId: user.id, user: user.id, reaction: newValue.string, remove: false) { result in
                    switch result {
                    case .success(()):
                        print("reacted!")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
            .onLongPressGesture {
                withAnimation {
                    showEmoji.toggle()
                }
            }
            
            HStack {
                Button {
                    liked.toggle()
                    like()
                } label: {
                    likeImage
                        .aspectRatio(contentMode: .fit)
                    
                }
                getLikes()
                if selectedEmoji != nil {
                    Text(selectedEmoji!.string)
                        .font(.system(size: 20))
                }
                ForEach(reactions) { reaction in
                    Text(reaction.reaction)
                        .font(.system(size: 20))
                }
                
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showEmoji) {
                HappyPanel(selectedEmoji: $selectedEmoji, isSearching: $searching)
                    .presentationDetents([.fraction(0.5), .fraction(0.9)], selection: $selectedDetent)
                    .onChange(of: searching) { newValue in
                        selectedDetent = .fraction(0.9)
                    }
        }
        .onTapGesture(count: 2) {
            withAnimation{
                liked = true
                like()
            }
        }
        .onTapGesture(count: 1) {
            withAnimation{
                showDetail.toggle()
            }
        }
        .onAppear {
            if image == nil {
                getImage()
            }
            getPP()
            if likes.contains(where: { $0 == AuthService.shared.loggedInUser?.id ?? "" }) {
                serverLiked = true
            }
        }
        .rotationEffect(Angle(degrees: -90))
        .frame(width: screen.width, height: screen.height)
    }
    
    var backgroundView: some View {
        if let image = image {
            return AnyView(
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(height: screen.height)
                        .ignoresSafeArea()
                        .blur(radius: 20)
                    Color.black
                        .opacity(showDetail ? 1.0 : 0.4)
                        .ignoresSafeArea()
                })
        } else {
            return AnyView(
                Color.black
                    .opacity(showDetail ? 1.0 : 0.4)
                    .ignoresSafeArea()
            )
        }
    }
    
    var userView: some View {
        HStack {
            ZStack {
                if let userPP = userPP {
                    userPP
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 33, height: 33)
                        .background(Color.black)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 33, height: 33)
                    ProgressView()
                }
            }
            Text(user)
                .font(Font.custom("Poppins-Regular", size: 20))
                .foregroundColor(Color.white)
            Spacer()
            Text(getTimePosted())
                .font(Font.custom("Poppins-Regular", size: 20))
                .foregroundColor(Color.white)
        }
    }
    
    func getLikes() -> some View {
        let friends = friendsViewModel.friends.compactMap { friend in
            if likes.contains(where: { $0 == friend.id }) {
                return friend
            } else {
                return nil
            }
        }
        
        guard !friends.isEmpty else {
            return Text(String(likes.count))
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color.white)
        }
        
        let likedFriends = friends.map({ $0.userName })
        
        if friends.count == 2 && likes.count == 2 {
            return Text("\(likedFriends[0]) and \(likedFriends[1]) liked this")
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color.white)
        }
        
        var text = ""
        
        _ = likedFriends.map { friend in
            text += "\(friend) "
        }
        
        text += "and \(likes.count - likedFriends.count) others liked this"
        
        return Text(text)
            .font(Font.custom("Poppins-Regular", size: 14))
            .foregroundColor(Color.white)
    }
    
    func like() {
        guard let id = AuthService.shared.loggedInUser?.id else { return }
        
        if likes.contains(where: { $0 == id }) {
            likes.removeAll(where: { $0 == id })
        } else {
            likes.append(id)
        }
        FirebaseHandler.shared.changeLike(selfId: id, user: self.id, remove: !liked) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(()):
                simpleSuccess()
            }
        }
    }
    
    func getTimePosted() -> String {
        if (timePosted / 60) < 60 {
            let time = Int((timePosted / 60).rounded())
            return "\(time)m ago"
        } else {
            return "\(Int((timePosted / 60 / 60).rounded()))h ago"
        }
    }
    
    func getImage() {
        guard image == nil else { return }
        //        let reference = Storage.storage().reference()
        //
        //        let task = reference.child("images/\(id)").getData(maxSize: 10 * 1024 * 1024) { data, error in
        //            if let error = error {
        //                print(error.localizedDescription)
        //            } else {
        //                guard let image = UIImage(data: data!) else { return }
        //                self.image = Image(uiImage: image)
        //                self.downloadDone = true
        //            }
        //        }
        //
        //        task.observe(.progress) { snapshot in
        //            let currentValue = (100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount))
        //            print(currentValue)
        //            self.currentDownload = currentValue
        //        }
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else { return }
            self.image = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
            withAnimation {
                self.downloadDone = true
            }
        }
    }
    
    func getPP() {
        guard userPP == nil else { return }
        let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
            print("percentage done:", progress.fractionCompleted)
        }
        let request = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        var id = id
        id += "profilePicture"
        
        request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
            guard let data = data else { return }
            self.userPP = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

@available(iOS 16.0, *)
struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(timePosted: 0.0, likes: ["12"], screen: CGRect(), reactions: [])
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
