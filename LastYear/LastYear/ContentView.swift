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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                if photoViewModel.allPhotos.isEmpty && photoViewModel.countFound == 0 {
                    VStack {
                        Text("Keine Bilder gefunden für " + photoViewModel.formattedDateOneYearAgo)
                            .font(Font.custom("Poppins-Bold", size: 24))
                            .foregroundColor(.white)
                    }
                } else if photoViewModel.allPhotos.count == photoViewModel.countFound {
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
                        if let image = photoViewModel.bestImage?.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .border(.white, width: 4)
                                .padding()
                                .cornerRadius(20)
                        }
                        HStack {
                            VStack {
                                Button {
                                    print("share")
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 32)
                                        .foregroundColor(.white)
                                }
                                Text("share")
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(Color("primary"))
                                
                            }
                            Spacer()
                            Text("26.09.2021")
                                .font(Font.custom("Poppins-Regular", size: 24))
                                .foregroundColor(.white)
                            Spacer()
                            NavigationLink {
                                AllPhotosView(photoViewModel: photoViewModel)
                            } label: {
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 32)
                                        .foregroundColor(.white)
                                    Text("+\(photoViewModel.countFound)")
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(Color("primary"))
                                }
                            }
                        }
                        .padding(12)
                    }
                    .padding(16)
                } else {
                    VStack(alignment: .center) {
                        Text("Loading your Meomories")
                            .font(Font.custom("Poppins-Bold", size: 24))
                            .foregroundColor(.white)
                        ProgressView(value: Double(photoViewModel.allPhotos.count), total: Double(photoViewModel.countFound))
                            .foregroundColor(Color("primary"))
                    }
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

struct SimpleProgressBar: View {
    
    @State var currentProgress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                    .frame(width: reader.size.width * 0.8, height: 20)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("primary"))
                    .frame(width: (reader.size.width * 0.8)*currentProgress, height: 20)
            }
        }
    }
}
