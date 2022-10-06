//
//  AllPhotosView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI

struct AllPhotosView: View {
    
    @ObservedObject var photoViewModel: PhotosViewModel
    @State var expanded: Bool = false
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                LogoView(size: 35)
                ZStack {
                    Text(photoViewModel.formattedDateOneYearAgo)
                        .font(Font.custom("Poppins-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    HStack {
                        Spacer()    
                        Button {
                            photoViewModel.getAllPhotos()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                ScrollView {
                    VStack {
                        let sortedImages = photoViewModel.allPhotos.sorted()
                        LazyVGrid(columns: layout) {
                            ForEach(sortedImages) { photo in
                                NavigationLink {
                                    PhotoDetailView(images: sortedImages, selected: photo.id)
                                } label: {
                                    PhotoCard(image: photo)
                                }
                            }
                        }
                        .padding(12)
                        if !photoViewModel.allPhotos.filter { $0.photoType == .screenshot }.isEmpty {
                            Button {
                                withAnimation {
                                    expanded.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("Show screenshots")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white)
                                        .rotationEffect(Angle(degrees: expanded ? 180 : 0))
                                }
                                .padding(.horizontal, 12)
                            }
                            .contentShape(Rectangle())
                            if expanded {
                                let sortedScreenshots = photoViewModel.allPhotos.filter { $0.photoType == .screenshot }.sorted()
                                LazyVGrid(columns: layout) {
                                    ForEach(sortedScreenshots) { photo in
                                        NavigationLink {
                                            PhotoDetailView(images: sortedScreenshots, selected: photo.id)
                                        } label: {
                                            PhotoCard(image: photo)
                                        }
                                    }
                                }
                                .padding(12)
                            }
                        }
                        Spacer()
                        VStack {
                            Text("\(photoViewModel.countFound) Photos found for " + photoViewModel.formattedDateOneYearAgo)
                                .font(Font.custom("Poppins-Regular", size: 18))
                                .foregroundColor(Color("primary"))
                            if photoViewModel.requestsFailed > 0 {
                                Text("\(photoViewModel.requestsFailed) Photos couldn't be imported")
                                    .font(Font.custom("Poppins-Regular", size: 18))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
}
