//
//  PhotoCard.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct PhotoCard: View {
    
    var image: PhotoData
    
    var body: some View {
        image.image
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(20)
    }
}

//struct PhotoCard_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoCard(image: <#Image#>)
//    }
//}
