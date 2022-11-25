//
//  MemoriesView.swift
//  LastYear
//
//  Created by Paul Kühnel on 07.11.22.
//

import SwiftUI

struct MemoriesView: View {
    @Namespace var loadingAnimation
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @ObservedObject var photoViewModel = PhotosViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var settingsShowing: Bool = false
    @State var buttonShowing: Bool = false
    @State var timeRemaining = 5
    @State var visible = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            AllPhotosView()
                .environmentObject(photoViewModel)
        }
        .onAppear {
            if photoViewModel.allPhotos.isEmpty {
                photoViewModel.load()
            }
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesView()
    }
}
