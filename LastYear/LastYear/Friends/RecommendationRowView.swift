//
//  RecommendationRowView.swift
//  LastYear
//
//  Created by Paul Kühnel on 16.11.22.
//

import SwiftUI
import AWSS3
import AWSCore

struct RecommendationRowView: View {
    
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    
    @State var user: LYUser
    @State var userProfilePicture: Image? = nil
    
    var body: some View {
        HStack {
            ZStack {
                if let userPP = userProfilePicture {
                    userPP
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 33, height: 33)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 33, height: 33)
                    ProgressView()
                }
            }
            .padding(.trailing, 8)
            Text(user.userName)
                .font(Font.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            Spacer()
            Button {
                friendsViewModel.sendFriendRequest(to: user.id)
            } label: {
                Text("Add")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color("gray"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            Button {
                friendsViewModel.recommendations.removeAll(where: { $0.id == user.id })
            } label: {
                Image(systemName: "xmark")
                    .font(Font.custom("Poppins-Regular", size: 20))
                    .foregroundColor(.white)
            }
        }
        .task {
            await getProfilePicture()
        }
    }
    
    func getProfilePicture() async {
        Task {
            let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
                print("percentage done:", progress.fractionCompleted)
            }
            let request = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = progressBlock
            
            var id = user.id
            id += "profilePicture"
            
            request.downloadData(fromBucket: "lastyearapp", key: id, expression: expression) { task, url, data, error in
                guard let data = data else { return }
                self.userProfilePicture = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
            }
        }
    }
    
}
