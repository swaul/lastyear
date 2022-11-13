//
//  DiscoverViewModel.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import Foundation

class DiscoverViewModel: ObservableObject {
    
    @Published var discoveries: [DiscoveryUpload] = []
    
    init() {
        getDiscoveries()
    }
    
    func getDiscoveries() {
        print("Load Discovery")        
        FirebaseHandler.shared.getDiscoveries{ result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let discoveries):
                self.discoveries = discoveries
            }
        }
    }
    
    func getNextDiscoveries() {
        print("Load more Discovery")
        FirebaseHandler.shared.getNextDiscoveries { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let discoveries):
                self.discoveries.append(contentsOf: discoveries)
            }
        }
    }
}
