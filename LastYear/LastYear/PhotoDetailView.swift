//
//  PhotoDetailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 26.09.22.
//

import SwiftUI

struct PhotoDetailView: View {
    
    var image: PhotoData
    
    var body: some View {
        image.image
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .padding()
    }
}

