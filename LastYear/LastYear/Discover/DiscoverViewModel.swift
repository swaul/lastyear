//
//  DiscoverViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation
import SwiftUI

class DiscoverViewModel: ObservableObject {
    
    @Published var discoveries: [DiscoveryUpload] = []
    @Published var loading: Bool = true
    
    func getDiscoveries() {
        print("Load Discovery")
        changeLoading(to: true)

        FirebaseHandler.shared.getDiscoveries(empty: discoveries.isEmpty) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self?.changeLoading(to: false)
            case .success(let discoveries):
                print("Found: Loaded \(discoveries.count) discoveries")
                let twentyFourHours: TimeInterval = 60 * 60 * 24
                let fun = discoveries.filter { upload in
                    if let date = upload.timePostedDate {
                        return Date.now.timeIntervalSince(date) < twentyFourHours
                    }
                    return false
                }
                self?.discoveries = fun
                self?.changeLoading(to: false)
            }
        }
    }
    
    func getNextDiscoveries() {
        print("Load more Discovery")

        changeLoading(to: true)
        FirebaseHandler.shared.getNextDiscoveries() { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self?.changeLoading(to: false)
            case .success(let discoveries):
                self?.discoveries.append(contentsOf: discoveries)
                self?.changeLoading(to: false)
            }
        }
    }
    
    func changeLoading(to: Bool) {
        withAnimation {
            print("discovery loading:", to)
            loading = to
        }
    }
}
