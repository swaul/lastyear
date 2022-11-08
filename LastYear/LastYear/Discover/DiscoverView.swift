//
//  HomeView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI

struct DiscoverView: View {
    
    var viewModel = DiscoverViewModel()
    
    var body: some View {
        VStack {
            Image("logoSmall")
                .padding(.bottom)
            ScrollView {
                VStack {
                    Text("Discovery")
                        .font(Font.custom("Poppins-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.vertical)
                    ForEach(viewModel.discoveries, id: \.id) { discovery in
                        if let time = discovery.timePostedDate {
                            let interval = Date.now.timeIntervalSince(time)
                            let twentyFourHours: TimeInterval = 60 * 60 * 24
                            if interval < twentyFourHours {
                                DiscoveryView(user: discovery.user, id: discovery.id, likes: discovery.likes)
                            }
                        }
                    }
                    Text("No more memories left...")
                        .font(Font.custom("Poppins-Regular", size: 20))
                        .foregroundColor(Color("gray"))
                        .padding()
                        .onAppear {
                            viewModel.getNextDiscoveries()
                        }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
