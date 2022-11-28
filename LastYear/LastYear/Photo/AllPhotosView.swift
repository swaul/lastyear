//
//  AllPhotosView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import ImageViewer
import Photos

struct AllPhotosView: View {
    
    @EnvironmentObject var photoViewModel: PhotosViewModel
    @State var expanded: Bool = false
    @State var selecting: Bool = false
    @State var detail: Bool = false
    @State var selected: String? = nil
    
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
                        if selecting {
                            Button {
                                withAnimation {
                                    selecting = false
                                }
                            } label: {
                                Text("Cancel")
                                    .padding(.horizontal, 16)
                            }
                        } else {
                            Button {
                                photoViewModel.getAllPhotos()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                ScrollView {
                    VStack {
                        let sortedImages = photoViewModel.allPhotos.sorted()
                        LazyVGrid(columns: layout, spacing: 0) {
                            ForEach(sortedImages.filter { $0.photoType != .screenshot }) { photo in
                                PhotoCard(asset: photo, selecting: $selecting)
                                    .padding(4)
                                .onTapGesture {
                                    withAnimation {
                                        if selecting {
                                            photo.selected.toggle()
                                        } else {
                                            selected = photo.assetID
                                            detail = true
                                        }
                                    }
                                }
                                .onLongPressGesture {
                                    photo.selected = true
                                    selecting = true
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
                                            PhotoDetailView(selected: .constant(photo.assetID))
                                        } label: {
                                            PhotoCard(asset: photo, selecting: $selecting)
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
//            if detail {
//                PhotoDetailView(images: photoViewModel.allPhotos, zoomScale: 1)
//                    .transition(.move(edge: .bottom))
//            }
        }
        .fullScreenCover(isPresented: $detail) {
            PhotoDetailView(selected: $selected)
        }
//        .overlay(ImageViewer(image: self.$selected, viewerShown: self.$detail, closeButtonTopRight: true))
    }
    
    func showDetail(selected: String) {
        self.selected = selected
        detail = true
    }
    
    func loadImageAsset(asset: String, targetSize: CGSize = PHImageManagerMaximumSize, completion: ((Image?) -> Void)?) async {
        guard let uiImage = try? await PhotoLibraryService.shared
            .fetchImage(
                byLocalIdentifier: asset,
                targetSize: targetSize
            ) else {
                return
            }
        completion?(Image(uiImage: uiImage))
    }
}
