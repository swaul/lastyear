//
//  AllPhotosView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI
import ImageViewer
import Photos
import AWSS3
import AWSCore

struct AllPhotosView: View {
    
    @EnvironmentObject var photoViewModel: PhotosViewModel
    @State var expanded: Bool = false
    @State var selecting: Bool = false
    @State var detail: Bool = false
    @State var selected: String? = nil
    
    @State var postedImage: Image? = nil
    @State var imageZoomed: Bool = false
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
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
                            photoViewModel.reloadPhotos()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            if Helper.checkPostOfToday(), let postedImage {
                HStack {
                    if !imageZoomed {
                        Text("Your post of today")
                            .transition(.scale(scale: 0, anchor: UnitPoint(x: 1, y: 1)))
                    }
                    
                    postedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            idealWidth: imageZoomed ? (UIScreen.screenWidth - 24) : .infinity,
                            maxHeight: imageZoomed ? .infinity : 60)
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {
                                imageZoomed.toggle()
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
                        .onAppear {
                            if sortedImages.isEmpty {
                                expanded = true
                            }
                        }
                        if expanded {
                            let sortedScreenshots = photoViewModel.allPhotos.filter { $0.photoType == .screenshot }.sorted()
                            LazyVGrid(columns: layout, spacing: 0) {
                                ForEach(sortedScreenshots) { photo in
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
                        }
                    }
                    Spacer()
                    VStack {
                        Text("\(photoViewModel.countFound ?? 0) Photos found for " + photoViewModel.formattedDateOneYearAgo)
                            .font(Font.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color("primary"))
                        if photoViewModel.requestsFailed > 0 {
                            Text("\(photoViewModel.requestsFailed) Photos couldn't be imported")
                                .font(Font.custom("Poppins-Regular", size: 18))
                                .foregroundColor(.red)
                        }
                    }
                }
                .task {
                    if Helper.checkPostOfToday() {
                        await getPost()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $detail) {
            PhotoDetailView(selected: $selected)
        }
    }
    
    func showDetail(selected: String) {
        self.selected = selected
        detail = true
    }
    
    func getPost() async {
        Task {
            guard postedImage == nil, let user = AuthService.shared.loggedInUser else { return }
            let progressBlock: AWSS3TransferUtilityProgressBlock = { task, progress in
                print("percentage done:", progress.fractionCompleted)
            }
            let request = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = progressBlock
            
            request.downloadData(fromBucket: "lastyearapp", key: user.id, expression: expression) { task, url, data, error in
                guard let data = data else { return }
                withAnimation {
                    self.postedImage = Image(uiImage: UIImage(data: data) ?? UIImage(named: "fallback")!)
                }
            }
        }
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
