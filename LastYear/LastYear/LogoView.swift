//
//  LogoView.swift
//  LastYear
//
//  Created by Paul Kühnel on 29.09.22.
//

import SwiftUI

struct LogoView: View {
    
    var size: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Text("About")
                .font(Font.custom("Poppins-Bold", size: size))
                .foregroundColor(.white)
            Text("Last")
                .font(Font.custom("Poppins-Bold", size: size))
                .foregroundColor(Color("primary"))
            Text("Year.")
                .font(Font.custom("Poppins-Bold", size: size))
                .foregroundColor(.white)
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(size: 35)
    }
}
