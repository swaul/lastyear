//
//  AllPhotosView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI

struct AllPhotosView: View {
    
    @ObservedObject var photoViewModel: PhotosViewModel
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color("primary")
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    LazyVGrid(columns: layout) {
                        ForEach(photoViewModel.allPhotos.sorted()) { photo in
                            NavigationLink {
                                PhotoDetailView(image: photo)
                            } label: {
                                PhotoCard(image: photo)
                            }
                        }
                    }
                    .padding(12)
                    VStack {
                        Text("\(photoViewModel.countFound) Photos found for " + photoViewModel.formattedDateOneYearAgo)
                            .font(Font.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color("primary"))
                        Text("\(photoViewModel.requestsFailed) Photos couldn't be imported")
                            .font(Font.custom("Poppins-Regular", size: 18))
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
