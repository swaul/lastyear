//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import FirebaseAnalytics

struct MainView: View {
    @Namespace var loadingAnimation
    
    @EnvironmentObject var authService: AuthService
    @ObservedObject var photoViewModel = PhotosViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var settingsShowing: Bool = false
    @State var buttonShowing: Bool = false
    @State var timeRemaining = 5
    @State var visible = false
    
    var content: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            switch photoViewModel.loadingState {
            case .done:
                ZStack {
                    Color("backgroundColor")
                        .ignoresSafeArea()
                    TabView {
                        imageView
                            .tabItem {
                                Label("Memories", systemImage: "photo")
                            }
                        
                        FriendsView()
                            .tabItem {
                                Label("Friends", systemImage: "person.3")
                            }
                            .badge(AuthService.shared.loggedInUser?.friendRequests.count ?? 0)
                    }
                }
            case .loading:
                VStack {
                    loadingView
                        .matchedGeometryEffect(id: "progressBar", in: loadingAnimation, anchor: .top)
                    if buttonShowing {
                        Button {
                            withAnimation {
                                photoViewModel.loadingState = .done
                            }
                        } label: {
                            Text("Load in background")
                                .font(Font.custom("Poppins-Bold", size: 24))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .onReceive(timer) { input in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        withAnimation {
                            buttonShowing = true
                        }
                    }
                }
                .onAppear {
                    LocalNotificationCenter.shared.scheduleTomorrows()
                }
            case .noPictures:
                VStack {
                    Text("Keine Bilder gefunden für " + photoViewModel.formattedDateOneYearAgo)
                        .font(Font.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.white)
                }
            default:
                VStack {
                    Spacer()
                    Text("idle")
                        .matchedGeometryEffect(id: "text", in: loadingAnimation)
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }
    
    var imageView: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                if visible {
                    topView
                        .transition(.move(edge: .top))
                }
                if photoViewModel.many {
                    loadingView
                        .matchedGeometryEffect(id: "progressBar", in: loadingAnimation, anchor: .top)
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                }
                if visible {
                    VStack {
                        NavigationLink {
                            if let image = photoViewModel.bestImage {
                                PhotoDetailView(images: photoViewModel.allPhotos.sorted(), selected: image.id)
                            }
                        } label: {
                            Image(uiImage: photoViewModel.bestImage?.waterMarkedImage ?? UIImage(named: "fallback")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(photoViewModel.allPhotos.isEmpty ? Color("primary") : .white, lineWidth: 3)
                                )
                                .padding()
                                .transition(.scale)
                        }
                    }
                }
                Spacer()
                if visible {
                    bottomView
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: visible)
                        .padding(12)
                }
            }
            .padding(16)
            .onAppear {
                withAnimation {
                    visible = true
                }
            }
        }
    }
    
    var loadingView: some View {
        VStack {
            if photoViewModel.loadingState == .loading {
                Text("Loading your Meomories")
                    .font(Font.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)
            } else {
                Text("Loading is taking longer than expected, so we are doing it in the background")
                    .font(Font.custom("Poppins-Light", size: 12))
                    .foregroundColor(.white)
            }
            if photoViewModel.countFound > 0 {
                ProgressView(value: Double(photoViewModel.test), total: Double(photoViewModel.countFound))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("primary")))
                    .padding(4)
                    .background(Color("backgroundColor"))
                    .cornerRadius(10)
                    .padding(.bottom)
                HStack(spacing: 0) {
                    Text(String(photoViewModel.test))
                        .font(Font.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.white)
                    Text("/")
                        .font(Font.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.white)
                    Text(String(photoViewModel.countFound))
                        .font(Font.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    var topView: some View {
        HStack {
            Spacer()
            LogoView(size: 35)
            Spacer()
            Button {
                settingsShowing = true
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $settingsShowing) {
                SettingsView()
            }
        }
    }
    
    var bottomView: some View {
        HStack {
            VStack {
                NavigationLink {
                    if let image = photoViewModel.bestImage {
                        PhotoDetailView(images: photoViewModel.allPhotos.sorted(), selected: image.id)
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
    }
}

extension UIImage {
    func addFilter(filter: FilterType) -> UIImage {
        guard filter != .none else { return self }
        let filter = CIFilter(name: filter.rawValue)
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        //Return the image
        return UIImage(cgImage: cgImage!)
    }
}

enum FilterType: String {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer =  "CIPhotoEffectTransfer"
    case none = ""
}
