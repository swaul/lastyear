//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authService: AuthService
    @ObservedObject var photoViewModel = PhotosViewModel()
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
        
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: layout) {
                        ForEach(photoViewModel.allPhotos) { photo in
                            NavigationLink {
                                PhotoDetailView(image: photo)
                            } label: {
                                PhotoCard(image: photo)
                            }
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
