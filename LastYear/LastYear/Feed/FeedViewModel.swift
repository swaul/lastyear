//
//  FeedViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 25.11.22.
//

import Foundation
import SwiftUI

public class FeedViewModel: ObservableObject {
    
    @Published var loading = false {
        didSet {
            print("loading: \(loading) memories: \(friendsMemories.count)")
        }
    }
    @Published var friendsMemories: [DiscoveryUpload] = []
    
    init() {
        getMemories()
    }
    
    func getMemories() {
        guard !loading else { return }
        print("Load Friends Memories")

        changeLoading(to: true)
        
        guard let user = AuthService.shared.loggedInUser else {
            self.changeLoading(to: false)
            return
        }
        
        FirebaseHandler.shared.getFriendsMemories(ids: user.friends, empty: friendsMemories.isEmpty) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self?.changeLoading(to: false)
            case .success(let discoveries):
                let twentyFourHours: TimeInterval = 60 * 60 * 24
                let fun = discoveries.filter { upload in
                    if let date = upload.timePostedDate {
                        return Date.now.timeIntervalSince(date) < twentyFourHours
                    }
                    return false
                }
                self?.friendsMemories = fun
                self?.changeLoading(to: false)
            }
        }
    }
    
    func changeLoading(to: Bool) {
        withAnimation {
            loading = to
        }
    }
    
    func getNextDiscoveries() {
        print("Load more Memories")
        changeLoading(to: true)
        
        guard let user = AuthService.shared.loggedInUser else { return }
        
        FirebaseHandler.shared.getNextMemories(ids: user.friends) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self?.changeLoading(to: false)
            case .success(let discoveries):
                self?.friendsMemories.append(contentsOf: discoveries)
                self?.changeLoading(to: false)
            }
        }
    }
}
