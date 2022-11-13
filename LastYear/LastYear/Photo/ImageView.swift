////
////  ImageView.swift
////  LastYear
////
////  Created by Paul Kühnel on 12.11.22.
////
//
//import SwiftUI
//import Photos
//
//struct ImageView: View {
//    
//    @Binding var zoomScale: CGFloat
//    @State private var previousZoomScale: CGFloat = 1
//    private let minZoomScale: CGFloat = 1
//    private let maxZoomScale: CGFloat = 5
//    
//    @State var image: Image? = nil
//    
//    var assetID: String
//    
//    var body: some View {
//        ZStack {
//            if let image = image {
//                GeometryReader { reader in
//                    ScrollView(
//                        [.vertical, .horizontal],
//                        showsIndicators: false
//                    ) {
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .cornerRadius(8)
//                            .frame(width: reader.size.width * max(minZoomScale, zoomScale))
//                    }
//                    .gesture(zoomGesture)
//                    .ignoresSafeArea()
//                }
//            } else {
//                Rectangle()
//                    .foregroundColor(.gray)
//                    .aspectRatio(1, contentMode: .fit)
//                ProgressView()
//            }
//        }
//        .ignoresSafeArea()
//        .task {
//            await loadImageAsset()
//        }
//        // Finally, when the view disappears, we need to free it
//        // up from the memory
//        .onDisappear {
//            image = nil
//        }
//    }
//    
//    func loadImageAsset(
//        targetSize: CGSize = PHImageManagerMaximumSize
//    ) async {
//        guard let uiImage = try? await PhotoLibraryService.shared
//            .fetchImage(
//                byLocalIdentifier: assetID,
//                targetSize: targetSize
//            ) else {
//            image = nil
//            return
//        }
//        image = Image(uiImage: uiImage)
//    }
//}
//
//
//
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(zoomScale: .constant(1), assetID: "")
//    }
//}
