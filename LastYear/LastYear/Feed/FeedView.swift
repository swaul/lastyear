//
//  FriendsView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.10.22.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @State var images: [Image] = []
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                if friendsViewModel.friends.isEmpty {
                    Text("No friends")
                    Spacer()
                } else {
                    Image("logoSmall")
                        .padding(.bottom)
                    ScrollView {
                        VStack {
                            Text("Your friends' memories:")
                                .font(Font.custom("Poppins-Regular", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical)
                            ForEach(friendsViewModel.friends, id: \.id) { friend in
                                if let time = friend.sharedLastYear,
                                   !time.isEmpty,
                                   let date = Formatters.dateTimeFormatter.date(from: time) {
                                    let interval = Date.now.timeIntervalSince(date)
                                    let twentyFourHours: TimeInterval = 60 * 60 * 24
                                    if interval < twentyFourHours {
                                        FriendLastYear(user: friend.userName, id: friend.id, timePosted: interval)
                                    }
                                }
                            }
                            Text("Want more? Add new friends!")
                                .font(Font.custom("Poppins-Regular", size: 20))
                                .foregroundColor(Color("gray"))
                                .padding()
                        }
                    }
                }
            }
        }
    }
    
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

extension Optional where Wrapped == String {
    
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
    
}
