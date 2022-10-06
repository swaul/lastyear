//
//  PhotoCard.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI
import CoreLocation

struct PhotoCard: View {
    
    var image: PhotoData
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
        
    var body: some View {
        VStack {
            image.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(20)
            if let date = image.date {
                Text(formatter.string(from: date))
                    .foregroundColor(.white)
            }
            Text(image.city ?? "No location")
                .foregroundColor(.white)
        }
    }
}

struct PhotoCard_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCard(image: PhotoData.dummy)
    }
}
