//
//  NetworkMonitor.swift
//  LastYear
//
//  Created by Paul Kühnel on 13.11.22.
//

import Foundation
import Network
import SwiftUI

// An enum to handle the network status
enum NetworkStatus: String {
    case connected
    case disconnected
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var status: NetworkStatus = .connected
  
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            // Monitor runs on a background thread so we need to publish
            // on the main thread
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("We're connected!")
                    self.status = .connected
                  

                } else {
                    print("No connection.")
                    withAnimation {
                        self.status = .disconnected
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
}
