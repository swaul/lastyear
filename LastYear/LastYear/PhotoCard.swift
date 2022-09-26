//
//  PhotoCard.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

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
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(20)
            if let date = image.date {
                Text(formatter.string(from: date))
            }
            Text(image.location?.description ?? "No location")
        }
    }
}

//struct PhotoCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoCard(image: <#Image#>)
//    }
//}
