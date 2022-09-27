//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseAnalytics

struct MainView: View {
    
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
                } else if (photoViewModel.allPhotos.count + photoViewModel.screenShots.count + photoViewModel.requestsFailed) == photoViewModel.countFound {
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
                        } else if photoViewModel.allPhotos.count >= 1 {
                            photoViewModel.allPhotos.first!.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .border(.white, width: 4)
                                .padding()
                                .cornerRadius(20)
                        }
                        HStack {
                            VStack {
                                NavigationLink {
                                    if let image = photoViewModel.bestImage {
                                        PhotoDetailView(image: image)
                                    }
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
                            Text(photoViewModel.formattedDateOneYearAgo)
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
                    .onAppear {
                        FirebaseAnalytics.Analytics.logEvent("app_opened", parameters: [
                          // 2
                          AnalyticsParameterStartDate: "start_date",
                          // 3
                          "strte_date": Formatters.dateTimeFormatter.string(from: Date.now) 
                        ])
                    }
                } else {
                    VStack(alignment: .center) {
                        Text("Loading your Meomories")
                            .font(Font.custom("Poppins-Bold", size: 24))
                            .foregroundColor(.white)
                        ProgressView(value: Double(photoViewModel.allPhotos.count + photoViewModel.screenShots.count + photoViewModel.requestsFailed), total: Double(photoViewModel.countFound))
                            .foregroundColor(Color("primary"))
                    }
                }
            }
        }
    }
    
}
