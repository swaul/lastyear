//
//  PhotoCard.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import Photos

struct PhotoCard: View {
    
    @ObservedObject var asset: PhotoData
    @State var loading: Bool = false
    @State private var image: Image?
    @Binding var selecting: Bool
        
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
        
    var body: some View {
//        VStack {
//            Image(uiImage: image.waterMarkedImage)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                .clipped()
//                .aspectRatio(1, contentMode: .fit)
//                .cornerRadius(8)
//            if let date = image.date {
//                Text(formatter.string(from: date))
//                    .foregroundColor(.white)
//            }
//        }
        ZStack {
            // Show the image if it's available
            if let image = image {
                GeometryReader { proxy in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.width
                        )
                        .clipped()
                }
                // We'll also make sure that the photo will
                // be square
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
                if asset.selected && selecting {
                    Color.white.opacity(0.5)
                        .cornerRadius(8)
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.blue)
                                .padding(6)
                        }
                    }
                }
            } else if loading == false {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .aspectRatio(1, contentMode: .fit)
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                }
                .onTapGesture {
                    Task {
                        await loadImageAsset()
                    }
                }
            } else {
                // Otherwise, show a gray rectangle with a
                // spinning progress view
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: .fit)
                ProgressView()
            }
        }
        // We need to use the task to work on a concurrent request to
        // load the image from the photo library service, which
        // is asynchronous work.
        .task {
            await loadImageAsset()
        }
        // Finally, when the view disappears, we need to free it
        // up from the memory
        .onDisappear {
            image = nil
        }
        .onChange(of: selecting) { newValue in
            if !newValue {
                asset.selected = false
            }
        }
    }
    
    func loadImageAsset(
        targetSize: CGSize = PHImageManagerMaximumSize
    ) async {
        loading = true
        print("sudoku started loading", asset.assetID)
        do {
            guard let uiImage = try await PhotoLibraryService.shared
                .fetchImage(
                    byLocalIdentifier: asset.assetID,
                    targetSize: targetSize
                ) else {
                loading = false
                image = nil
                print("sudoku Couldnt loadd image", asset.assetID)
                return
            }
            loading = false
            print("sudoku Loaded image", asset.assetID)
            image = Image(uiImage: uiImage)
        } catch let error {
            print(error)
        }
    }
}

struct PhotoCard_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCard(asset: PhotoData.dummy, selecting: .constant(false))
    }
}
