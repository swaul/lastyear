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
                HStack(spacing: 0) {
                    Text("About")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(.white)
                    Text("Last")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(Color("primary"))
                    Text("Year.")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(.white)
                }
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
                        if !photoViewModel.screenShots.isEmpty {
                            Button {
                                withAnimation {
                                    expanded.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("Show screenshots")
                                        .font(Font.custom("Poppins-Regular", size: 18))
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal, 16)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white)
                                        .rotationEffect(Angle(degrees: expanded ? 180 : 0))
                                        .padding(.horizontal, 16)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            if expanded {
                                LazyVGrid(columns: layout) {
                                    ForEach(photoViewModel.screenShots.sorted()) { photo in
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
                        Spacer()
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
}
